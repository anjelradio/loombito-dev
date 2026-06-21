import gzip
import hashlib
import json
from datetime import date, datetime
from enum import Enum
from pathlib import Path
from uuid import UUID
import uuid

from fastapi import HTTPException
import sqlalchemy as sa
from sqlmodel import SQLModel, select

from app.core.config import settings
from app.dependencies.auth import DBSession
from app.modules.auth.models import User
from app.modules.schools.models import SchoolRole
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import SchoolBackup
from app.modules.system.repositories import BackupRepository
from app.modules.system.schemas import (
    CreateSchoolBackupResponse,
    DeleteSchoolBackupResponse,
    RestoreSchoolBackupResponse,
    SchoolBackupRead,
)

# ---------------------------------------------------------------------------
# Tablas globales/catálogo que NO pertenecen a ninguna escuela en particular y
# que por tanto deben quedar FUERA del ciclo de backup/restore.
# ---------------------------------------------------------------------------
_EXCLUDED_TABLES = {
    # Tablas de infraestructura del sistema de backup
    "school_backups",
    "audit_logs",
    # Entidades raíz globales (existen fuera de cualquier colegio)
    "school",
    "user",
    # Catálogos globales compartidos por todos los colegios
    "levels",
    "plans",
    "evaluation_types",
    "attendance_statuses",
    # Tokens de dispositivos: pertenecen al usuario, no a un colegio
    "push_tokens",
    # Reportes generados on-demand — no son datos críticos de restaurar
    "report_runs",
}

# Tablas que SÍ deben incluirse pero cuya pertenencia a una escuela es
# implícita (no tienen columna school_id directa).
_IMPLICIT_TABLES = {
    # Cursos (school_id) → course_subjects / course_students
    "course_subjects",
    "course_students",
    # Estudiantes (school_id) → student_parent / student_parent_invite
    "student_parent",
    "student_parent_invite",
    # Estudiantes (school_id) → student_debts
    # student_debts → student_payments
    "student_debts",
    "student_payments",
    # school_subscriptions (school_id) → subscription_payments
    "subscription_payments",
}


class BackupService:
    def __init__(self, db: DBSession):
        self.db = db
        self.repo = BackupRepository(db)
        self.school_repo = SchoolRepository(db)
        self.school_user_repo = SchoolUserRepository(db)

    # ------------------------------------------------------------------
    # Autorización
    # ------------------------------------------------------------------

    def _ensure_owner(self, school_id: UUID, user: User) -> None:
        """Verifica que la escuela exista y que el usuario sea su OWNER."""
        school = self.school_repo.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        membership = self.school_user_repo.get_by_user_and_school(user.id, school_id)
        if not membership or membership.role != SchoolRole.OWNER:
            raise HTTPException(
                status_code=403, detail="Solo el owner puede gestionar backups"
            )

    # ------------------------------------------------------------------
    # Serialización / deserialización de valores
    # ------------------------------------------------------------------

    def _to_json_value(self, value):
        """Convierte valores no serializables a formato JSON seguro."""
        if isinstance(value, UUID):
            return str(value)
        if isinstance(value, datetime):
            return value.isoformat()
        if isinstance(value, date):
            return value.isoformat()
        if isinstance(value, Enum):
            return value.value
        return value

    def _from_json_value(self, column, value):
        """Convierte valores JSON del snapshot a tipos Python esperados por la DB."""
        if value is None:
            return None

        column_type = column.type
        if isinstance(column_type, sa.Uuid):
            if isinstance(value, UUID):
                return value
            return uuid.UUID(str(value))

        if isinstance(column_type, sa.DateTime):
            if isinstance(value, datetime):
                return value
            return datetime.fromisoformat(str(value))

        if isinstance(column_type, sa.Date):
            if isinstance(value, date):
                return value
            return date.fromisoformat(str(value))

        return value

    def _coerce_row_for_insert(self, table, row: dict) -> dict:
        """Ajusta una fila de snapshot para INSERT según tipos de columnas SQLAlchemy."""
        coerced = {}
        for column in table.columns:
            key = column.name
            if key not in row:
                continue
            coerced[key] = self._from_json_value(column, row[key])
        return coerced

    # ------------------------------------------------------------------
    # Selección de tablas incluidas en backup / restore
    # ------------------------------------------------------------------

    def _get_school_tables(self):
        """
        Devuelve las tablas ordenadas topológicamente que forman parte del
        backup de un colegio. Se mantiene el orden de sorted_tables para que
        los INSERTs respeten las FKs y los DELETEs se hagan en orden inverso.
        """
        tables = []
        for table in SQLModel.metadata.sorted_tables:
            if table.name in _EXCLUDED_TABLES:
                continue
            if "school_id" in table.c or table.name in _IMPLICIT_TABLES:
                tables.append(table)
        return tables

    # ------------------------------------------------------------------
    # Helpers para obtener IDs por cadena de dependencias
    # ------------------------------------------------------------------

    def _list_course_ids_for_school(self, school_id: UUID) -> list[UUID]:
        """IDs de cursos activos del colegio (para filtrar course_subjects/students)."""
        t = SQLModel.metadata.tables.get("courses")
        if t is None:
            return []
        rows = self.db.execute(
            select(t.c.id).where(t.c.school_id == school_id)
        ).all()
        return [row[0] for row in rows]

    def _list_student_ids_for_school(self, school_id: UUID) -> list[UUID]:
        """IDs de todos los estudiantes del colegio."""
        t = SQLModel.metadata.tables.get("students")
        if t is None:
            return []
        rows = self.db.execute(
            select(t.c.id).where(t.c.school_id == school_id)
        ).all()
        return [row[0] for row in rows]

    def _list_student_debt_ids_for_school(self, school_id: UUID) -> list[UUID]:
        """IDs de deudas pertenecientes a estudiantes del colegio."""
        student_ids = self._list_student_ids_for_school(school_id)
        if not student_ids:
            return []
        t = SQLModel.metadata.tables.get("student_debts")
        if t is None:
            return []
        rows = self.db.execute(
            select(t.c.id).where(t.c.student_id.in_(student_ids))
        ).all()
        return [row[0] for row in rows]

    def _list_subscription_ids_for_school(self, school_id: UUID) -> list[UUID]:
        """IDs de suscripciones del colegio."""
        t = SQLModel.metadata.tables.get("school_subscriptions")
        if t is None:
            return []
        rows = self.db.execute(
            select(t.c.id).where(t.c.school_id == school_id)
        ).all()
        return [row[0] for row in rows]

    # ------------------------------------------------------------------
    # Cláusula de filtro por colegio para cada tabla
    # ------------------------------------------------------------------

    def _scope_clause_for_table(self, table, school_id: UUID):
        """
        Construye la cláusula WHERE apropiada para filtrar (o eliminar) las
        filas que pertenecen al colegio dado, independientemente de si la
        tabla tiene school_id directo o sólo tiene dependencias implícitas.
        """
        # Caso 1: columna school_id directa — el más común
        if "school_id" in table.c:
            return table.c.school_id == school_id

        # Caso 2: course_subjects / course_students — via course_id
        if table.name in {"course_subjects", "course_students"}:
            course_ids = self._list_course_ids_for_school(school_id)
            if not course_ids:
                return sa.false()
            return table.c.course_id.in_(course_ids)

        # Caso 3: student_parent / student_parent_invite / student_debts
        #         — via student_id
        if table.name in {"student_parent", "student_parent_invite", "student_debts"}:
            student_ids = self._list_student_ids_for_school(school_id)
            if not student_ids:
                return sa.false()
            return table.c.student_id.in_(student_ids)

        # Caso 4: student_payments — via student_debt_id
        if table.name == "student_payments":
            debt_ids = self._list_student_debt_ids_for_school(school_id)
            if not debt_ids:
                return sa.false()
            return table.c.student_debt_id.in_(debt_ids)

        # Caso 5: subscription_payments — via school_subscription_id
        if table.name == "subscription_payments":
            sub_ids = self._list_subscription_ids_for_school(school_id)
            if not sub_ids:
                return sa.false()
            return table.c.school_subscription_id.in_(sub_ids)

        # Fallback seguro — no debería llegar aquí si _IMPLICIT_TABLES está bien
        return sa.false()

    # ------------------------------------------------------------------
    # Utilidades de almacenamiento
    # ------------------------------------------------------------------

    def _backup_root(self) -> Path:
        """Ruta base local para almacenar archivos de backup comprimidos."""
        root = Path(settings.BACKUP_STORAGE_DIR)
        if not root.is_absolute():
            root = Path.cwd() / root
        root.mkdir(parents=True, exist_ok=True)
        return root

    def _to_read(self, row: SchoolBackup) -> SchoolBackupRead:
        """Mapea entidad de backup a schema de salida."""
        return SchoolBackupRead(
            id=row.id,
            school_id=row.school_id,
            created_by_user_id=row.created_by_user_id,
            file_name=row.file_name,
            file_size_bytes=row.file_size_bytes,
            checksum_sha256=row.checksum_sha256,
            status=row.status,
            created_date=row.created_date,
            restored_date=row.restored_date,
        )

    # ------------------------------------------------------------------
    # Operaciones públicas
    # ------------------------------------------------------------------

    def create_school_backup(
        self, school_id: UUID, user: User
    ) -> CreateSchoolBackupResponse:
        """
        Crea un snapshot JSON comprimido (gzip) de todos los datos del colegio.
        Incluye todas las tablas con school_id directo y las tablas cuya
        pertenencia al colegio es implícita (via student_id, course_id, etc.).
        """
        self._ensure_owner(school_id, user)

        tables = self._get_school_tables()
        snapshot = {
            "schema_version": 2,
            "school_id": str(school_id),
            "created_at": datetime.utcnow().isoformat(),
            "created_by_user_id": str(user.id),
            "tables": {},
        }

        for table in tables:
            scope_clause = self._scope_clause_for_table(table, school_id)
            rows = self.db.execute(select(table).where(scope_clause)).mappings().all()
            snapshot["tables"][table.name] = [
                {key: self._to_json_value(value) for key, value in dict(row).items()}
                for row in rows
            ]

        content_bytes = json.dumps(snapshot, ensure_ascii=False).encode("utf-8")
        checksum = hashlib.sha256(content_bytes).hexdigest()

        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        file_name = f"backup_school_{school_id}_{timestamp}.json.gz"
        school_dir = self._backup_root() / str(school_id)
        school_dir.mkdir(parents=True, exist_ok=True)
        file_path = school_dir / file_name

        with gzip.open(file_path, "wb") as gz:
            gz.write(content_bytes)

        backup = SchoolBackup(
            school_id=school_id,
            created_by_user_id=user.id,
            file_name=file_name,
            file_path=str(file_path),
            file_size_bytes=file_path.stat().st_size,
            checksum_sha256=checksum,
            status="created",
        )
        self.repo.create(backup)
        self.db.commit()
        self.db.refresh(backup)

        return CreateSchoolBackupResponse(backup=self._to_read(backup))

    def list_school_backups(
        self, school_id: UUID, user: User
    ) -> list[SchoolBackupRead]:
        """Lista todos los backups activos de una escuela."""
        self._ensure_owner(school_id, user)
        rows = self.repo.list_active_by_school(school_id)
        return [self._to_read(row) for row in rows]

    def restore_school_backup(
        self, school_id: UUID, backup_id: UUID, user: User
    ) -> RestoreSchoolBackupResponse:
        """
        Restaura un backup con la estrategia wipe-then-insert:

        1. Valida checksum SHA-256 del archivo antes de tocar la DB.
        2. Elimina en orden INVERSO (tablas hijo primero) para respetar FKs.
        3. Inserta en orden DIRECTO (topológico) para respetar FKs.
        4. Todo ocurre en una sola transacción; cualquier error hace rollback.
        """
        self._ensure_owner(school_id, user)

        backup = self.repo.get_active_by_id_and_school(backup_id, school_id)
        if not backup:
            raise HTTPException(status_code=404, detail="Backup no encontrado")

        file_path = Path(backup.file_path)
        if not file_path.exists():
            raise HTTPException(
                status_code=404,
                detail="Archivo de backup no encontrado en almacenamiento",
            )

        with gzip.open(file_path, "rb") as gz:
            raw = gz.read()

        if hashlib.sha256(raw).hexdigest() != backup.checksum_sha256:
            raise HTTPException(
                status_code=400, detail="Checksum inválido — el backup está corrupto"
            )

        payload = json.loads(raw.decode("utf-8"))
        if not isinstance(payload, dict) or "tables" not in payload:
            raise HTTPException(
                status_code=400, detail="Contenido de backup inválido o formato desconocido"
            )

        snapshot_tables: dict = payload["tables"]

        tables = self._get_school_tables()

        try:
            # ---- Paso 1: eliminar datos actuales (orden inverso = hijos primero)
            for table in reversed(tables):
                scope_clause = self._scope_clause_for_table(table, school_id)
                self.db.execute(table.delete().where(scope_clause))

            # ---- Paso 2: insertar desde snapshot (orden topológico = padres primero)
            for table in tables:
                rows = snapshot_tables.get(table.name, [])
                if not rows:
                    continue
                for row in rows:
                    if isinstance(row, dict):
                        prepared_row = self._coerce_row_for_insert(table, row)
                        self.db.execute(table.insert().values(**prepared_row))

            # ---- Paso 3: marcar el backup como restaurado
            backup.status = "restored"
            backup.restored_date = datetime.utcnow()
            self.repo.update(backup)
            self.db.commit()
            self.db.refresh(backup)

        except Exception as exc:
            self.db.rollback()
            raise HTTPException(
                status_code=500,
                detail=f"No se pudo restaurar el backup: {exc}",
            )

        return RestoreSchoolBackupResponse(
            backup_id=backup.id,
            restored=True,
            restored_date=backup.restored_date,
        )

    def delete_school_backup(
        self, school_id: UUID, backup_id: UUID, user: User
    ) -> DeleteSchoolBackupResponse:
        """Elimina un backup — borra el archivo físico y lo marca como eliminado."""
        self._ensure_owner(school_id, user)

        backup = self.repo.get_active_by_id_and_school(backup_id, school_id)
        if not backup:
            raise HTTPException(status_code=404, detail="Backup no encontrado")

        file_path = Path(backup.file_path)
        if file_path.exists():
            file_path.unlink()

        backup.state = False
        backup.status = "deleted"
        backup.deleted_date = datetime.utcnow()
        self.repo.update(backup)
        self.db.commit()

        return DeleteSchoolBackupResponse(backup_id=backup.id, deleted=True)

    def create_all_schools_backup_cron(self) -> dict:
        """
        Llamado exclusivamente por el endpoint cron — no requiere autenticación de owner.
        Itera todas las escuelas activas del sistema y genera un backup para cada una.
        Los errores en una escuela no detienen el proceso para las demás.

        Retorna un resumen con escuelas procesadas, exitosas y fallidas.
        """
        schools = self.school_repo.list_all_active()

        results: list[dict] = []
        succeeded = 0
        failed = 0

        for school in schools:
            try:
                tables = self._get_school_tables()
                snapshot = {
                    "schema_version": 2,
                    "school_id": str(school.id),
                    "created_at": datetime.utcnow().isoformat(),
                    "created_by_user_id": "cron",
                    "tables": {},
                }

                for table in tables:
                    scope_clause = self._scope_clause_for_table(table, school.id)
                    rows = (
                        self.db.execute(select(table).where(scope_clause))
                        .mappings()
                        .all()
                    )
                    snapshot["tables"][table.name] = [
                        {
                            key: self._to_json_value(value)
                            for key, value in dict(row).items()
                        }
                        for row in rows
                    ]

                content_bytes = json.dumps(snapshot, ensure_ascii=False).encode("utf-8")
                checksum = hashlib.sha256(content_bytes).hexdigest()

                timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
                file_name = f"backup_school_{school.id}_{timestamp}.json.gz"
                school_dir = self._backup_root() / str(school.id)
                school_dir.mkdir(parents=True, exist_ok=True)
                file_path = school_dir / file_name

                with gzip.open(file_path, "wb") as gz:
                    gz.write(content_bytes)

                backup = SchoolBackup(
                    school_id=school.id,
                    created_by_user_id=school.id,  # sentinel: mismo ID de escuela indica origen cron
                    file_name=file_name,
                    file_path=str(file_path),
                    file_size_bytes=file_path.stat().st_size,
                    checksum_sha256=checksum,
                    status="created",
                )
                self.repo.create(backup)
                self.db.commit()

                succeeded += 1
                results.append({"school_id": str(school.id), "status": "ok", "file": file_name})

            except Exception as exc:
                self.db.rollback()
                failed += 1
                results.append({"school_id": str(school.id), "status": "error", "detail": str(exc)})

        return {
            "total": len(schools),
            "succeeded": succeeded,
            "failed": failed,
            "results": results,
        }
