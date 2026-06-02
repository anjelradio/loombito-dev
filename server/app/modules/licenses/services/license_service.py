from datetime import datetime
from uuid import UUID

from fastapi import HTTPException
from sqlmodel import Session

from app.core.config import settings
from app.dependencies.auth import CurrentActorContext
from app.modules.licenses.models import StudentLicense
from app.modules.licenses.repositories import StudentLicenseRepository
from app.modules.licenses.schemas import (
    StudentLicenseCreate,
    StudentLicenseRead,
    StudentLicenseReason,
    StudentLicenseUpdate,
)
from app.modules.schools.repositories import SchoolRepository
from app.modules.students.repositories import StudentParentRepository, StudentRepository


class LicenseService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.student = StudentRepository(db)
        self.student_parent = StudentParentRepository(db)
        self.license = StudentLicenseRepository(db)

    def _ensure_parent_and_student(self, school_id: UUID, student_id: UUID, actor: CurrentActorContext):
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        student = self.student.get_active_by_id_in_school(school_id, student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")

        parent_link = self.student_parent.get_active_by_user_and_student(actor.user.id, student_id)
        if not parent_link:
            raise HTTPException(status_code=403, detail="No autorizado para este estudiante")

    def _validate_reason(self, reason: str):
        normalized = reason.strip().lower()
        if normalized not in StudentLicenseReason.values():
            raise HTTPException(status_code=422, detail="Motivo de licencia invalido")
        return normalized

    def _validate_monthly_limit(self, school_id: UUID, student_id: UUID):
        now = datetime.utcnow()
        month_start = datetime(year=now.year, month=now.month, day=1)
        if now.month == 12:
            month_end = datetime(year=now.year + 1, month=1, day=1)
        else:
            month_end = datetime(year=now.year, month=now.month + 1, day=1)

        total = self.license.count_active_in_month_by_student(
            school_id=school_id,
            student_id=student_id,
            month_start=month_start,
            month_end=month_end,
        )
        if total >= settings.MAX_LICENSES_PER_MONTH:
            raise HTTPException(
                status_code=422,
                detail=f"Se alcanzo el maximo de {settings.MAX_LICENSES_PER_MONTH} licencias en este mes.",
            )

    def create_student_license(
        self,
        school_id: UUID,
        student_id: UUID,
        payload: StudentLicenseCreate,
        actor: CurrentActorContext,
    ) -> StudentLicenseRead:
        self._ensure_parent_and_student(school_id, student_id, actor)

        if payload.start_date > payload.end_date:
            raise HTTPException(status_code=422, detail="La fecha de inicio no puede ser mayor a la fecha de fin")

        reason = self._validate_reason(payload.reason)
        self._validate_monthly_limit(school_id, student_id)

        row = StudentLicense(
            school_id=school_id,
            student_id=student_id,
            author_user_id=actor.user.id,
            reason=reason,
            description=payload.description.strip(),
            start_date=payload.start_date,
            end_date=payload.end_date,
        )
        self.license.create(row)
        self.db.commit()
        self.db.refresh(row)
        return StudentLicenseRead.model_validate(row)

    def list_student_licenses(
        self,
        school_id: UUID,
        student_id: UUID,
        actor: CurrentActorContext,
    ) -> list[StudentLicenseRead]:
        self._ensure_parent_and_student(school_id, student_id, actor)
        rows = self.license.list_active_by_student(school_id, student_id)
        return [StudentLicenseRead.model_validate(row) for row in rows]

    def update_student_license(
        self,
        school_id: UUID,
        student_id: UUID,
        license_id: UUID,
        payload: StudentLicenseUpdate,
        actor: CurrentActorContext,
    ) -> StudentLicenseRead:
        self._ensure_parent_and_student(school_id, student_id, actor)

        row = self.license.get_active_by_id(license_id)
        if not row:
            raise HTTPException(status_code=404, detail="Licencia no encontrada")

        if payload.start_date > payload.end_date:
            raise HTTPException(status_code=422, detail="La fecha de inicio no puede ser mayor a la fecha de fin")

        reason = self._validate_reason(payload.reason)

        row.reason = reason
        row.description = payload.description.strip()
        row.start_date = payload.start_date
        row.end_date = payload.end_date
        self.license.update(row)
        self.db.commit()
        self.db.refresh(row)
        return StudentLicenseRead.model_validate(row)

    def delete_student_license(
        self,
        school_id: UUID,
        student_id: UUID,
        license_id: UUID,
        actor: CurrentActorContext,
    ) -> None:
        self._ensure_parent_and_student(school_id, student_id, actor)

        row = self.license.get_active_by_id(license_id)
        if not row:
            raise HTTPException(status_code=404, detail="Licencia no encontrada")

        self.license.soft_delete(row)
        self.db.commit()
