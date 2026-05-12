from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.academic.models import EvaluationWeight, Term
from app.modules.academic.permissions import ensure_admin_or_owner
from app.modules.academic.repositories import EvaluationWeightRepository, TermRepository
from app.modules.academic.schemas import (
    EvaluationWeightLevelRead,
    EvaluationWeightRead,
    EvaluationWeightUpsert,
    TermCreate,
    TermRead,
    TermUpdate,
)
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class TermService:
    def __init__(self, db: Session):
        self.db = db
        self.term = TermRepository(db)
        self.evaluation_weight = EvaluationWeightRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    def _ensure_school_and_permissions(self, school_id: UUID, user_id: UUID) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")
        ensure_admin_or_owner(self.school_user, user_id, school_id)

    def list_terms(self, school_id: UUID, user_id: UUID) -> list[TermRead]:
        self._ensure_school_and_permissions(school_id, user_id)
        terms = self.term.list_active_by_school(school_id)
        return [TermRead.model_validate(term) for term in terms]

    def create_term(
        self, school_id: UUID, payload: TermCreate, actor: CurrentActorContext
    ) -> TermRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)

        existing_name = self.term.get_by_name_in_school(school_id, payload.name)
        if existing_name:
            raise HTTPException(status_code=409, detail="El nombre del trimestre ya existe")

        has_overlap = self.term.has_date_overlap(school_id, payload.start_date, payload.end_date)
        if has_overlap:
            raise HTTPException(status_code=409, detail="Las fechas del trimestre se solapan")

        try:
            term = Term(
                name=payload.name,
                start_date=payload.start_date,
                end_date=payload.end_date,
                school_id=school_id,
            )
            self.term.create(term)
            self.db.commit()
            self.db.refresh(term)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.CREATE,
                description="Creacion de trimestre exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return TermRead.model_validate(term)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo crear el trimestre")
        except Exception:
            self.db.rollback()
            raise

    def update_term(
        self,
        school_id: UUID,
        term_id: UUID,
        payload: TermUpdate,
        actor: CurrentActorContext,
    ) -> TermRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)

        term = self.term.get_active_by_id_in_school(school_id, term_id)
        if not term:
            raise HTTPException(status_code=404, detail="Trimestre no encontrado")

        existing_name = self.term.get_by_name_in_school(school_id, payload.name)
        if existing_name and existing_name.id != term_id:
            raise HTTPException(status_code=409, detail="El nombre del trimestre ya existe")

        has_overlap = self.term.has_date_overlap(
            school_id, payload.start_date, payload.end_date, exclude_term_id=term_id
        )
        if has_overlap:
            raise HTTPException(status_code=409, detail="Las fechas del trimestre se solapan")

        try:
            term.name = payload.name
            term.start_date = payload.start_date
            term.end_date = payload.end_date
            self.term.update(term)
            self.db.commit()
            self.db.refresh(term)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.UPDATE,
                description="Actualizacion de trimestre exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return TermRead.model_validate(term)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo actualizar el trimestre")
        except Exception:
            self.db.rollback()
            raise

    def delete_term(self, school_id: UUID, term_id: UUID, actor: CurrentActorContext) -> None:
        self._ensure_school_and_permissions(school_id, actor.user.id)

        term = self.term.get_active_by_id_in_school(school_id, term_id)
        if not term:
            raise HTTPException(status_code=404, detail="Trimestre no encontrado")

        self.term.delete(term)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de trimestre exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    def list_evaluation_weights(
        self, school_id: UUID, user_id: UUID
    ) -> list[EvaluationWeightLevelRead]:
        self._ensure_school_and_permissions(school_id, user_id)
        rows = self.evaluation_weight.list_levels_with_weights(school_id)

        return [
            EvaluationWeightLevelRead(
                school_level_id=school_level_id,
                level_name=level_name,
                has_configured=evaluation_weight_id is not None,
                ser=ser,
                saber=saber,
                hacer=hacer,
                autoevaluacion=autoevaluacion,
            )
            for (
                school_level_id,
                level_name,
                evaluation_weight_id,
                ser,
                saber,
                hacer,
                autoevaluacion,
            ) in rows
        ]

    def upsert_evaluation_weight(
        self,
        school_id: UUID,
        school_level_id: UUID,
        payload: EvaluationWeightUpsert,
        actor: CurrentActorContext,
    ) -> EvaluationWeightRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)

        levels = self.evaluation_weight.list_levels_with_weights(school_id)
        valid_school_level_ids = {row[0] for row in levels}
        if school_level_id not in valid_school_level_ids:
            raise HTTPException(status_code=400, detail="El nivel no pertenece a esta escuela")

        model = self.evaluation_weight.get_by_school_and_level(school_id, school_level_id)

        try:
            if model:
                model.ser = payload.ser
                model.saber = payload.saber
                model.hacer = payload.hacer
                model.autoevaluacion = payload.autoevaluacion
                self.evaluation_weight.update(model)
            else:
                model = EvaluationWeight(
                    school_id=school_id,
                    school_level_id=school_level_id,
                    ser=payload.ser,
                    saber=payload.saber,
                    hacer=payload.hacer,
                    autoevaluacion=payload.autoevaluacion,
                )
                self.evaluation_weight.create(model)

            self.db.commit()
            self.db.refresh(model)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.UPDATE,
                description="Guardado de ponderacion de evaluacion exitoso",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return EvaluationWeightRead.model_validate(model)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo guardar la ponderacion")
        except Exception:
            self.db.rollback()
            raise
