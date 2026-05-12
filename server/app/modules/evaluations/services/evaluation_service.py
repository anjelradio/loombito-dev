from datetime import date
from math import ceil
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.evaluations.permissions import ensure_teacher_in_school
from app.modules.evaluations.models import Evaluation
from app.modules.evaluations.repositories.evaluation_repository import (
    EvaluationContextRepository,
    EvaluationRepository,
    EvaluationTypeRepository,
)
from app.modules.evaluations.schemas import (
    EvaluationCreate,
    EvaluationRead,
    EvaluationTermOptionRead,
    EvaluationTypeRead,
    EvaluationUpdate,
    PaginatedEvaluation,
)
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class EvaluationService:
    def __init__(self, db: Session):
        self.db = db
        self.evaluation = EvaluationRepository(db)
        self.evaluation_type = EvaluationTypeRepository(db)
        self.context = EvaluationContextRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    def _ensure_school_exists(self, school_id: UUID) -> None:
        # Valida que la escuela exista.
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

    def _validate_term_date(self, term, presentation_date: date) -> None:
        # Valida que la fecha de presentacion caiga dentro del trimestre.
        if presentation_date < term.start_date or presentation_date > term.end_date:
            raise HTTPException(
                status_code=400,
                detail="La fecha de presentacion debe estar dentro del trimestre seleccionado",
            )

    def _validate_teacher_assignment_access(self, school_id: UUID, teacher_id: UUID, assignment_id: UUID):
        # Valida que la asignacion exista y pertenezca al docente.
        assignment = self.context.get_active_assignment_by_id_in_school(school_id, assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")
        if assignment.teacher_id != teacher_id:
            raise HTTPException(status_code=403, detail="No puedes gestionar evaluaciones de esta asignacion")
        return assignment

    def _validate_evaluation_type(self, evaluation_type_id: UUID):
        # Valida que el tipo de evaluacion exista y este activo.
        evaluation_type = self.evaluation_type.get_active_by_id(evaluation_type_id)
        if not evaluation_type:
            raise HTTPException(status_code=400, detail="Tipo de evaluacion no valido")
        return evaluation_type

    def _validate_term(self, school_id: UUID, term_id: UUID):
        # Valida que el trimestre exista y este activo en la escuela.
        term = self.context.get_active_term_by_id_in_school(school_id, term_id)
        if not term:
            raise HTTPException(status_code=400, detail="Trimestre no valido")
        return term

    def _ensure_teacher_owns_evaluation(self, school_id: UUID, teacher_id: UUID, evaluation_id: UUID) -> Evaluation:
        # Valida que la evaluacion exista y pertenezca a una asignacion del docente.
        evaluation = self.evaluation.get_active_by_id_in_school(school_id, evaluation_id)
        if not evaluation:
            raise HTTPException(status_code=404, detail="Evaluacion no encontrada")

        assignment = self.context.get_active_assignment_by_id_in_school(school_id, evaluation.assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion de la evaluacion no encontrada")
        if assignment.teacher_id != teacher_id:
            raise HTTPException(status_code=403, detail="No puedes gestionar esta evaluacion")
        return evaluation

    def _to_evaluation_read(self, row) -> EvaluationRead:
        # Mapea una fila con joins al esquema de lectura.
        evaluation, evaluation_type_name, term_name = row
        return EvaluationRead(
            id=evaluation.id,
            name=evaluation.name,
            description=evaluation.description,
            presentation_date=evaluation.presentation_date,
            term_id=evaluation.term_id,
            term_name=term_name,
            assignment_id=evaluation.assignment_id,
            evaluation_type_id=evaluation.evaluation_type_id,
            evaluation_type_name=evaluation_type_name,
            school_id=evaluation.school_id,
            is_closed=evaluation.is_closed,
        )

    def list_evaluation_types(self, school_id: UUID, user_id: UUID) -> list[EvaluationTypeRead]:
        # Lista tipos de evaluacion para formularios del docente.
        self._ensure_school_exists(school_id)
        ensure_teacher_in_school(self.school_user, user_id, school_id)
        types = self.evaluation_type.list_active()
        return [EvaluationTypeRead(id=item.id, name=item.name) for item in types]

    def list_term_options(self, school_id: UUID, user_id: UUID) -> list[EvaluationTermOptionRead]:
        # Lista trimestres activos y marca el trimestre vigente.
        self._ensure_school_exists(school_id)
        ensure_teacher_in_school(self.school_user, user_id, school_id)
        today = date.today()
        terms = self.context.list_active_terms_by_school(school_id)
        return [
            EvaluationTermOptionRead(
                id=term.id,
                name=term.name,
                start_date=term.start_date,
                end_date=term.end_date,
                is_active=term.start_date <= today <= term.end_date,
            )
            for term in terms
        ]

    def create_evaluation(
        self, school_id: UUID, payload: EvaluationCreate, actor: CurrentActorContext
    ) -> EvaluationRead:
        # Crea una evaluacion para una asignacion del docente.
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        self._validate_teacher_assignment_access(school_id, teacher_membership.id, payload.assignment_id)
        self._validate_evaluation_type(payload.evaluation_type_id)
        term = self._validate_term(school_id, payload.term_id)
        self._validate_term_date(term, payload.presentation_date)

        try:
            evaluation = Evaluation(
                name=payload.name,
                description=payload.description,
                presentation_date=payload.presentation_date,
                assignment_id=payload.assignment_id,
                term_id=payload.term_id,
                evaluation_type_id=payload.evaluation_type_id,
                school_id=school_id,
            )
            self.evaluation.create(evaluation)
            self.db.commit()
            self.db.refresh(evaluation)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo crear la evaluacion")
        except Exception:
            self.db.rollback()
            raise

        row = self.evaluation.get_read_row_by_id(school_id, evaluation.id)
        if not row:
            raise HTTPException(status_code=404, detail="Evaluacion no encontrada")
        self.audit_logger.safe_log_school_success(
            action=AuditAction.CREATE,
            description="Creacion de evaluacion exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
        return self._to_evaluation_read(row)

    def update_evaluation(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        payload: EvaluationUpdate,
        actor: CurrentActorContext,
    ) -> EvaluationRead:
        # Actualiza una evaluacion existente del docente.
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        evaluation = self._ensure_teacher_owns_evaluation(school_id, teacher_membership.id, evaluation_id)
        self._validate_evaluation_type(payload.evaluation_type_id)
        term = self._validate_term(school_id, payload.term_id)
        self._validate_term_date(term, payload.presentation_date)

        try:
            evaluation.name = payload.name
            evaluation.description = payload.description
            evaluation.presentation_date = payload.presentation_date
            evaluation.term_id = payload.term_id
            evaluation.evaluation_type_id = payload.evaluation_type_id
            self.evaluation.update(evaluation)
            self.db.commit()
            self.db.refresh(evaluation)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo actualizar la evaluacion")
        except Exception:
            self.db.rollback()
            raise

        row = self.evaluation.get_read_row_by_id(school_id, evaluation.id)
        if not row:
            raise HTTPException(status_code=404, detail="Evaluacion no encontrada")
        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Actualizacion de evaluacion exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
        return self._to_evaluation_read(row)

    def delete_evaluation(
        self, school_id: UUID, evaluation_id: UUID, actor: CurrentActorContext
    ) -> None:
        # Elimina logicamente una evaluacion del docente.
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        evaluation = self._ensure_teacher_owns_evaluation(school_id, teacher_membership.id, evaluation_id)
        self.evaluation.soft_delete_grades_by_evaluation(school_id, evaluation.id)
        self.evaluation.delete(evaluation)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de evaluacion exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    def list_evaluations_by_assignment(
        self,
        school_id: UUID,
        assignment_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
    ) -> PaginatedEvaluation:
        # Lista evaluaciones paginadas para una asignacion del docente.
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, user_id, school_id)
        self._validate_teacher_assignment_access(school_id, teacher_membership.id, assignment_id)

        total = self.evaluation.count_by_assignment(school_id, assignment_id)
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        rows = (
            self.evaluation.list_paginated_by_assignment(
                school_id,
                assignment_id,
                per_page=per_page,
                page=current_page,
            )
            if total_pages > 0
            else []
        )

        return PaginatedEvaluation(
            evaluations=[self._to_evaluation_read(row) for row in rows],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    def get_evaluation_by_id(self, school_id: UUID, evaluation_id: UUID, user_id: UUID) -> EvaluationRead:
        # Obtiene detalle de evaluacion para repoblar formularios.
        self._ensure_school_exists(school_id)
        teacher_membership = ensure_teacher_in_school(self.school_user, user_id, school_id)
        self._ensure_teacher_owns_evaluation(school_id, teacher_membership.id, evaluation_id)

        row = self.evaluation.get_read_row_by_id(school_id, evaluation_id)
        if not row:
            raise HTTPException(status_code=404, detail="Evaluacion no encontrada")
        return self._to_evaluation_read(row)
