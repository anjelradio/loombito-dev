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


class BackupService:
    def __init__(self, db: DBSession):
        self.db = db
        self.repo = BackupRepository(db)
        self.school_repo = SchoolRepository(db)
        self.school_user_repo = SchoolUserRepository(db)

    # Verifica escuela y que el usuario sea owner de la escuela.
    def _ensure_owner(self, school_id: UUID, user: User) -> None:
        school = self.school_repo.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        membership = self.school_user_repo.get_by_user_and_school(user.id, school_id)
        if not membership or membership.role != SchoolRole.OWNER:
            raise HTTPException(status_code=403, detail="Solo el owner puede gestionar backups")

    # Convierte valores no serializables a formato JSON seguro.
    def _to_json_value(self, value):
        if isinstance(value, UUID):
            return str(value)
        if isinstance(value, datetime):
            return value.isoformat()
        if isinstance(value, date):
            return value.isoformat()
        if isinstance(value, Enum):
            return value.value
        return value

    # Convierte valores JSON del snapshot a tipos Python esperados por la DB.
    def _from_json_value(self, column, value):
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

    # Ajusta una fila de snapshot para insert segun tipos de columnas SQLAlchemy.
    def _coerce_row_for_insert(self, table, row: dict) -> dict:
        coerced = {}
        for column in table.columns:
            key = column.name
            if key not in row:
                continue
            coerced[key] = self._from_json_value(column, row[key])
        return coerced

    # Obtiene tablas incluidas en backup/restauracion por escuela.
    def _get_school_tables(self):
        excluded = {"school_backups", "audit_logs"}
        explicitly_included_without_school_id = {"course_subjects", "course_students"}
        tables = []
        for table in SQLModel.metadata.sorted_tables:
            if table.name in excluded:
                continue
            if "school_id" in table.c or table.name in explicitly_included_without_school_id:
                tables.append(table)
        return tables

    # Devuelve IDs de cursos actuales para filtrar tablas puente sin school_id.
    def _list_course_ids_for_school(self, school_id: UUID) -> list[UUID]:
        courses_table = SQLModel.metadata.tables.get("courses")
        if courses_table is None:
            return []
        rows = self.db.execute(
            select(courses_table.c.id).where(
                courses_table.c.school_id == school_id,
                courses_table.c.state == True,
            )
        ).all()
        return [row[0] for row in rows]

    # Construye clausula de alcance por escuela para cada tabla incluida.
    def _scope_clause_for_table(self, table, school_id: UUID):
        if "school_id" in table.c:
            return table.c.school_id == school_id

        if table.name in {"course_subjects", "course_students"}:
            course_ids = self._list_course_ids_for_school(school_id)
            if not course_ids:
                return sa.false()
            return table.c.course_id.in_(course_ids)

        return sa.false()

    # Ruta base local para almacenar archivos de backup comprimidos.
    def _backup_root(self) -> Path:
        root = Path(settings.BACKUP_STORAGE_DIR)
        if not root.is_absolute():
            root = Path.cwd() / root
        root.mkdir(parents=True, exist_ok=True)
        return root

    # Mapea entidad de backup a schema de salida.
    def _to_read(self, row: SchoolBackup) -> SchoolBackupRead:
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

    # Crea snapshot JSON comprimido de todos los datos de una escuela.
    def create_school_backup(self, school_id: UUID, user: User) -> CreateSchoolBackupResponse:
        self._ensure_owner(school_id, user)

        tables = self._get_school_tables()
        snapshot = {
            "schema_version": 1,
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

    # Lista backups activos de una escuela.
    def list_school_backups(self, school_id: UUID, user: User) -> list[SchoolBackupRead]:
        self._ensure_owner(school_id, user)
        rows = self.repo.list_active_by_school(school_id)
        return [self._to_read(row) for row in rows]

    # Restaura backup con estrategia wipe + insert para school_id.
    def restore_school_backup(self, school_id: UUID, backup_id: UUID, user: User) -> RestoreSchoolBackupResponse:
        self._ensure_owner(school_id, user)
        backup = self.repo.get_active_by_id_and_school(backup_id, school_id)
        if not backup:
            raise HTTPException(status_code=404, detail="Backup no encontrado")

        file_path = Path(backup.file_path)
        if not file_path.exists():
            raise HTTPException(status_code=404, detail="Archivo de backup no encontrado en almacenamiento")

        with gzip.open(file_path, "rb") as gz:
            raw = gz.read()

        if hashlib.sha256(raw).hexdigest() != backup.checksum_sha256:
            raise HTTPException(status_code=400, detail="Checksum invalido para backup")

        payload = json.loads(raw.decode("utf-8"))
        snapshot_tables = payload.get("tables") if isinstance(payload, dict) else None
        if not isinstance(snapshot_tables, dict):
            raise HTTPException(status_code=400, detail="Contenido de backup invalido")

        tables = self._get_school_tables()
        try:
            for table in reversed(tables):
                scope_clause = self._scope_clause_for_table(table, school_id)
                self.db.execute(table.delete().where(scope_clause))

            for table in tables:
                rows = snapshot_tables.get(table.name, [])
                if not rows:
                    continue
                for row in rows:
                    if isinstance(row, dict):
                        prepared_row = self._coerce_row_for_insert(table, row)
                        self.db.execute(table.insert().values(**prepared_row))

            backup.status = "restored"
            backup.restored_date = datetime.utcnow()
            self.repo.update(backup)
            self.db.commit()
            self.db.refresh(backup)
        except Exception as exc:
            self.db.rollback()
            raise HTTPException(status_code=500, detail=f"No se pudo restaurar el backup: {exc}")

        return RestoreSchoolBackupResponse(
            backup_id=backup.id,
            restored=True,
            restored_date=backup.restored_date,
        )

    # Elimina backup (archivo y metadata logica) de una escuela.
    def delete_school_backup(self, school_id: UUID, backup_id: UUID, user: User) -> DeleteSchoolBackupResponse:
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
