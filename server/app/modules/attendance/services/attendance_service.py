from datetime import date
from math import ceil
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.attendance.models import AttendanceRecord, AttendanceSession
from app.modules.attendance.permissions import ensure_teacher_in_school
from app.modules.attendance.repositories import (
    AttendanceContextRepository,
    AttendanceRecordRepository,
    AttendanceSessionRepository,
    AttendanceStatusRepository,
)
from app.modules.attendance.schemas import (
    AttendanceFinalizeSummaryRead,
    AttendanceGradebookRowRead,
    AttendanceRecordUpsert,
    AttendanceSessionCreate,
    AttendanceSessionRead,
    AttendanceStatusRead,
    PaginatedAttendanceSession,
)
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class AttendanceService:
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = AttendanceSessionRepository(db)
        self.status_repo = AttendanceStatusRepository(db)
        self.record_repo = AttendanceRecordRepository(db)
        self.context_repo = AttendanceContextRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    # Valida que la escuela exista.
    def _ensure_school_exists(self, school_id: UUID) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

    # Valida que la asignacion exista y pertenezca al docente.
    def _validate_teacher_assignment_access(self, school_id: UUID, teacher_id: UUID, assignment_id: UUID):
        assignment = self.context_repo.get_active_assignment_by_id_in_school(school_id, assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")
        if assignment.teacher_id != teacher_id:
            raise HTTPException(status_code=403, detail="No puedes gestionar asistencias de esta asignacion")
        return assignment

    # Valida que la sesion exista y pertenezca a una asignacion del docente.
    def _ensure_teacher_owns_session(self, school_id: UUID, teacher_id: UUID, session_id: UUID) -> AttendanceSession:
        session = self.session_repo.get_active_by_id_in_school(school_id, session_id)
        if not session:
            raise HTTPException(status_code=404, detail="Sesion de asistencia no encontrada")
        assignment = self.context_repo.get_active_assignment_by_id_in_school(school_id, session.assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion de la sesion no encontrada")
        if assignment.teacher_id != teacher_id:
            raise HTTPException(status_code=403, detail="No puedes gestionar esta sesion")
        return session

    # Mapea una fila con joins al esquema de lectura.
    def _to_session_read(self, row) -> AttendanceSessionRead:
        session, term_name = row
        return AttendanceSessionRead(
            id=session.id,
            name=session.name,
            attendance_date=session.attendance_date,
            is_closed=session.is_closed,
            assignment_id=session.assignment_id,
            term_id=session.term_id,
            term_name=term_name,
            school_id=session.school_id,
        )

    # Lista estados de asistencia para formularios del docente.
    def list_status_options(self, school_id: UUID, user_id: UUID) -> list[AttendanceStatusRead]:
        self._ensure_school_exists(school_id)
        ensure_teacher_in_school(self.school_user, user_id, school_id)
        statuses = self.status_repo.list_active()
        return [AttendanceStatusRead(id=item.id, name=item.name) for item in statuses]

    # Crea una sesion de asistencia para una asignacion del docente.
    def create_session(
        self, school_id: UUID, payload: AttendanceSessionCreate, actor: CurrentActorContext
    ) -> AttendanceSessionRead:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        self._validate_teacher_assignment_access(school_id, teacher_membership.id, payload.assignment_id)

        term = self.context_repo.get_active_term_by_date_in_school(school_id, payload.attendance_date)
        if not term:
            raise HTTPException(
                status_code=400,
                detail="No existe un trimestre activo para la fecha seleccionada",
            )

        try:
            session = AttendanceSession(
                name=f"Asistencia {payload.attendance_date.isoformat()}",
                attendance_date=payload.attendance_date,
                assignment_id=payload.assignment_id,
                term_id=term.id,
                school_id=school_id,
            )
            self.session_repo.create(session)
            self.db.commit()
            self.db.refresh(session)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=409,
                detail="Ya existe una sesion de asistencia para esta materia en la fecha seleccionada",
            )

        row = self.session_repo.get_read_row_by_id(school_id, session.id)
        if not row:
            raise HTTPException(status_code=404, detail="Sesion de asistencia no encontrada")
        self.audit_logger.safe_log_school_success(
            action=AuditAction.CREATE,
            description="Creacion de sesion de asistencia exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
        return self._to_session_read(row)

    # Lista sesiones paginadas para una asignacion del docente.
    def list_sessions_by_assignment(
        self,
        school_id: UUID,
        assignment_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
    ) -> PaginatedAttendanceSession:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, user_id, school_id)
        self._validate_teacher_assignment_access(school_id, teacher_membership.id, assignment_id)

        total = self.session_repo.count_by_assignment(school_id, assignment_id)
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        rows = (
            self.session_repo.list_paginated_by_assignment(
                school_id,
                assignment_id,
                per_page=per_page,
                page=current_page,
            )
            if total_pages > 0
            else []
        )

        return PaginatedAttendanceSession(
            sessions=[self._to_session_read(row) for row in rows],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    # Obtiene detalle de sesion para pantalla de toma de asistencia.
    def get_session_by_id(self, school_id: UUID, session_id: UUID, user_id: UUID) -> AttendanceSessionRead:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, user_id, school_id)
        self._ensure_teacher_owns_session(school_id, teacher_membership.id, session_id)

        row = self.session_repo.get_read_row_by_id(school_id, session_id)
        if not row:
            raise HTTPException(status_code=404, detail="Sesion de asistencia no encontrada")
        return self._to_session_read(row)

    # Elimina logicamente una sesion y sus registros de asistencia.
    def delete_session(
        self, school_id: UUID, session_id: UUID, actor: CurrentActorContext
    ) -> None:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        session = self._ensure_teacher_owns_session(school_id, teacher_membership.id, session_id)
        self.record_repo.soft_delete_by_session(school_id, session.id)
        self.session_repo.delete(session)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de sesion de asistencia exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    # Lista estudiantes del curso con su estado de asistencia en la sesion.
    def list_gradebook_by_session(
        self,
        school_id: UUID,
        session_id: UUID,
        user_id: UUID,
    ) -> list[AttendanceGradebookRowRead]:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, user_id, school_id)
        session = self._ensure_teacher_owns_session(school_id, teacher_membership.id, session_id)

        course_id = self.context_repo.get_course_id_by_assignment(session.assignment_id)
        if not course_id:
            raise HTTPException(status_code=404, detail="No se pudo resolver el curso de la sesion")

        students = self.context_repo.list_active_students_by_course(school_id, course_id)
        records = self.record_repo.list_active_by_session(school_id, session.id)
        status_map = {status.id: status.name for status in self.status_repo.list_active()}
        records_by_student = {record.student_id: record for record in records}

        rows: list[AttendanceGradebookRowRead] = []
        for student in students:
            record = records_by_student.get(student.id)
            rows.append(
                AttendanceGradebookRowRead(
                    student_id=student.id,
                    first_name=student.first_name,
                    last_name=student.last_name,
                    attendance_record_id=record.id if record else None,
                    status_id=record.status_id if record else None,
                    status_name=status_map.get(record.status_id) if record else None,
                    observation=record.observation if record else None,
                    status="registrado" if record else "sin_registrar",
                )
            )
        return rows

    # Crea o actualiza el estado de asistencia de un estudiante.
    def upsert_record(
        self,
        school_id: UUID,
        session_id: UUID,
        student_id: UUID,
        payload: AttendanceRecordUpsert,
        actor: CurrentActorContext,
    ) -> AttendanceGradebookRowRead:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        session = self._ensure_teacher_owns_session(school_id, teacher_membership.id, session_id)

        status = self.status_repo.get_active_by_id(payload.status_id)
        if not status:
            raise HTTPException(status_code=400, detail="Estado de asistencia no valido")

        course_id = self.context_repo.get_course_id_by_assignment(session.assignment_id)
        if not course_id:
            raise HTTPException(status_code=404, detail="No se pudo resolver el curso de la sesion")

        students = self.context_repo.list_active_students_by_course(school_id, course_id)
        student = next((item for item in students if item.id == student_id), None)
        if not student:
            raise HTTPException(status_code=403, detail="El estudiante no pertenece al curso de esta sesion")

        record = self.record_repo.get_active_by_session_and_student(school_id, session.id, student_id)
        if record:
            record.status_id = payload.status_id
            record.observation = payload.observation
            self.record_repo.update(record)
        else:
            record = AttendanceRecord(
                status_id=payload.status_id,
                observation=payload.observation,
                attendance_session_id=session.id,
                student_id=student_id,
                school_id=school_id,
            )
            self.record_repo.create(record)

        self.db.commit()
        self.db.refresh(record)

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Registro de asistencia actualizado exitosamente",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        return AttendanceGradebookRowRead(
            student_id=student.id,
            first_name=student.first_name,
            last_name=student.last_name,
            attendance_record_id=record.id,
            status_id=record.status_id,
            status_name=status.name,
            observation=record.observation,
            status="registrado",
        )

    # Completa faltantes con estado Falta y marca la sesion como finalizada.
    def finalize_session(
        self, school_id: UUID, session_id: UUID, actor: CurrentActorContext
    ) -> AttendanceFinalizeSummaryRead:
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        session = self._ensure_teacher_owns_session(school_id, teacher_membership.id, session_id)

        absent_status = self.status_repo.get_active_by_name("Falta")
        if not absent_status:
            raise HTTPException(status_code=400, detail="No existe el estado Falta configurado")

        course_id = self.context_repo.get_course_id_by_assignment(session.assignment_id)
        if not course_id:
            raise HTTPException(status_code=404, detail="No se pudo resolver el curso de la sesion")

        students = self.context_repo.list_active_students_by_course(school_id, course_id)
        records = self.record_repo.list_active_by_session(school_id, session.id)
        recorded_student_ids = {record.student_id for record in records}

        created_missing = 0
        for student in students:
            if student.id in recorded_student_ids:
                continue
            self.record_repo.create(
                AttendanceRecord(
                    status_id=absent_status.id,
                    observation=None,
                    attendance_session_id=session.id,
                    student_id=student.id,
                    school_id=school_id,
                )
            )
            created_missing += 1

        session.is_closed = True
        self.session_repo.update(session)
        self.db.commit()

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Finalizacion de sesion de asistencia exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        return AttendanceFinalizeSummaryRead(
            created_missing=created_missing,
            total_students=len(students),
        )
