from math import ceil
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.academic.models import Subject
from app.modules.academic.permissions import ensure_admin_or_owner
from app.modules.academic.repositories import SubjectRepository
from app.modules.academic.schemas import (
    PaginatedSubject,
    SubjectCreate,
    SubjectRead,
    SubjectUpdate,
)
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class SubjectService:
    def __init__(self, db: Session):
        self.db = db
        self.subject = SubjectRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    def create(
        self, school_id: UUID, payload: SubjectCreate, actor: CurrentActorContext
    ) -> SubjectRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        if self.subject.get_by_name_in_school(school_id, payload.name):
            raise HTTPException(
                status_code=409,
                detail="El nombre de la materia ya esta en uso en esta escuela",
            )

        try:
            subject = Subject(name=payload.name, school_id=school_id)
            self.subject.create(subject)
            self.db.commit()
            self.db.refresh(subject)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.CREATE,
                description="Creacion de materia exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return SubjectRead.model_validate(subject)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=409,
                detail="El nombre de la materia ya esta en uso en esta escuela",
            )
        except Exception:
            self.db.rollback()
            raise

    def list_by_school(
        self,
        school_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
        search: str | None = None,
    ) -> PaginatedSubject:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, user_id, school_id)

        total = self.subject.count_active_by_school(school_id, search)
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        subjects = (
            self.subject.list_paginated_by_school(
                school_id,
                search,
                per_page=per_page,
                page=current_page,
            )
            if total_pages > 0
            else []
        )

        return PaginatedSubject(
            subjects=[SubjectRead.model_validate(subject) for subject in subjects],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    def update(
        self,
        school_id: UUID,
        subject_id: UUID,
        payload: SubjectUpdate,
        actor: CurrentActorContext,
    ) -> SubjectRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        subject = self.subject.get_active_by_id_in_school(school_id, subject_id)
        if not subject:
            raise HTTPException(status_code=404, detail="Materia no encontrada")

        existing = self.subject.get_by_name_in_school(school_id, payload.name)
        if existing and existing.id != subject_id:
            raise HTTPException(
                status_code=409,
                detail="El nombre de la materia ya esta en uso en esta escuela",
            )

        try:
            subject.name = payload.name
            self.subject.update(subject)
            self.db.commit()
            self.db.refresh(subject)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.UPDATE,
                description="Actualizacion de materia exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return SubjectRead.model_validate(subject)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=409,
                detail="El nombre de la materia ya esta en uso en esta escuela",
            )
        except Exception:
            self.db.rollback()
            raise

    def delete(self, school_id: UUID, subject_id: UUID, actor: CurrentActorContext) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        subject = self.subject.get_active_by_id_in_school(school_id, subject_id)
        if not subject:
            raise HTTPException(status_code=404, detail="Materia no encontrada")

        self.subject.delete(subject)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de materia exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
