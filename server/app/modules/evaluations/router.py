from uuid import UUID

from fastapi import APIRouter, Query, Response, status

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.evaluations.schemas import (
    CalculateTermAverageSummaryRead,
    EvaluationCreate,
    EvaluationRead,
    EvaluationTermOptionRead,
    EvaluationTypeRead,
    EvaluationUpdate,
    PaginatedEvaluation,
    StudentTermAverageRowRead,
    TermAverageTermOptionRead,
)
from app.modules.evaluations.services import EvaluationService, TermSubjectAverageService

router = APIRouter(prefix="/evaluations", tags=["Evaluaciones"])


@router.get("/schools/{school_id}/evaluation-types", response_model=list[EvaluationTypeRead])
def list_evaluation_types(school_id: UUID, db: DBSession, actor: CurrentActor):
    return EvaluationService(db).list_evaluation_types(school_id, actor.user.id)


@router.get("/schools/{school_id}/term-options", response_model=list[EvaluationTermOptionRead])
def list_term_options(school_id: UUID, db: DBSession, actor: CurrentActor):
    return EvaluationService(db).list_term_options(school_id, actor.user.id)


@router.post("/schools/{school_id}/evaluations", response_model=EvaluationRead)
def create_evaluation(
    school_id: UUID,
    db: DBSession,
    payload: EvaluationCreate,
    actor: CurrentActor,
):
    return EvaluationService(db).create_evaluation(school_id, payload, actor)


@router.put("/schools/{school_id}/evaluations/{evaluation_id}", response_model=EvaluationRead)
def update_evaluation(
    school_id: UUID,
    evaluation_id: UUID,
    db: DBSession,
    payload: EvaluationUpdate,
    actor: CurrentActor,
):
    return EvaluationService(db).update_evaluation(school_id, evaluation_id, payload, actor)


@router.delete("/schools/{school_id}/evaluations/{evaluation_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_evaluation(school_id: UUID, evaluation_id: UUID, db: DBSession, actor: CurrentActor):
    EvaluationService(db).delete_evaluation(school_id, evaluation_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/schools/{school_id}/assignments/{assignment_id}/evaluations",
    response_model=PaginatedEvaluation,
)
def list_evaluations_by_assignment(
    school_id: UUID,
    assignment_id: UUID,
    db: DBSession,
    actor: CurrentActor,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
):
    return EvaluationService(db).list_evaluations_by_assignment(
        school_id,
        assignment_id,
        actor.user.id,
        per_page,
        page,
    )


@router.get("/schools/{school_id}/evaluations/{evaluation_id}", response_model=EvaluationRead)
def get_evaluation_by_id(school_id: UUID, evaluation_id: UUID, db: DBSession, actor: CurrentActor):
    return EvaluationService(db).get_evaluation_by_id(school_id, evaluation_id, actor.user.id)


@router.get("/schools/{school_id}/term-average-options", response_model=list[TermAverageTermOptionRead])
def list_term_average_options(school_id: UUID, db: DBSession, actor: CurrentActor):
    return TermSubjectAverageService(db).list_term_average_options(school_id, actor.user.id)


@router.get(
    "/schools/{school_id}/assignments/{assignment_id}/terms/{term_id}/averages",
    response_model=list[StudentTermAverageRowRead],
)
def list_term_averages_by_assignment(
    school_id: UUID,
    assignment_id: UUID,
    term_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return TermSubjectAverageService(db).list_by_assignment_and_term(
        school_id,
        assignment_id,
        term_id,
        actor.user.id,
    )


@router.post(
    "/schools/{school_id}/assignments/{assignment_id}/terms/{term_id}/averages/calculate",
    response_model=CalculateTermAverageSummaryRead,
)
def calculate_term_averages_by_assignment(
    school_id: UUID,
    assignment_id: UUID,
    term_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return TermSubjectAverageService(db).calculate_by_assignment_and_term(
        school_id,
        assignment_id,
        term_id,
        actor,
    )
