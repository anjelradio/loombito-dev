from uuid import UUID

from fastapi import APIRouter, Query, Response, status

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.students.schemas import (
    EvaluationFinalizeSummaryRead,
    PaginatedStudent,
    StudentCreate,
    StudentEvaluationGradeRowRead,
    StudentEvaluationGradeUpsert,
    StudentRead,
    StudentUpdate,
)
from app.modules.students.services import StudentService

router = APIRouter(prefix="/students", tags=["Estudiantes"])


@router.get("/schools/{school_id}/evaluations/{evaluation_id}/students", response_model=list[StudentRead])
def list_students_by_evaluation(
    school_id: UUID,
    evaluation_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return StudentService(db).list_by_evaluation_for_teacher(
        school_id, evaluation_id, actor.user.id
    )


@router.get(
    "/schools/{school_id}/evaluations/{evaluation_id}/gradebook",
    response_model=list[StudentEvaluationGradeRowRead],
)
def list_gradebook_by_evaluation(
    school_id: UUID,
    evaluation_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return StudentService(db).list_gradebook_by_evaluation_for_teacher(
        school_id,
        evaluation_id,
        actor.user.id,
    )


@router.put(
    "/schools/{school_id}/evaluations/{evaluation_id}/students/{student_id}/grade",
    response_model=StudentEvaluationGradeRowRead,
)
def upsert_evaluation_grade(
    school_id: UUID,
    evaluation_id: UUID,
    student_id: UUID,
    db: DBSession,
    payload: StudentEvaluationGradeUpsert,
    actor: CurrentActor,
):
    return StudentService(db).upsert_evaluation_grade_for_teacher(
        school_id,
        evaluation_id,
        student_id,
        payload,
        actor,
    )


@router.post(
    "/schools/{school_id}/evaluations/{evaluation_id}/finalize",
    response_model=EvaluationFinalizeSummaryRead,
)
def finalize_evaluation(
    school_id: UUID,
    evaluation_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return StudentService(db).finalize_evaluation_for_teacher(
        school_id,
        evaluation_id,
        actor,
    )


@router.get("/schools/{school_id}/courses/{course_id}", response_model=PaginatedStudent)
def list_students_by_course(
    school_id: UUID,
    course_id: UUID,
    db: DBSession,
    actor: CurrentActor,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
    search: str | None = Query(None, min_length=1, description="Busqueda por nombre"),
):
    return StudentService(db).list_by_course(
        school_id, course_id, actor.user.id, per_page, page, search
    )


@router.post("/schools/{school_id}/courses/{course_id}", response_model=StudentRead)
def create_student_in_course(
    school_id: UUID,
    course_id: UUID,
    db: DBSession,
    payload: StudentCreate,
    actor: CurrentActor,
):
    return StudentService(db).create_in_course(school_id, course_id, payload, actor)


@router.put("/schools/{school_id}/students/{student_id}", response_model=StudentRead)
def update_student(
    school_id: UUID,
    student_id: UUID,
    db: DBSession,
    payload: StudentUpdate,
    actor: CurrentActor,
):
    return StudentService(db).update(school_id, student_id, payload, actor)


@router.delete(
    "/schools/{school_id}/courses/{course_id}/students/{student_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def unlink_student_from_course(
    school_id: UUID,
    course_id: UUID,
    student_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    StudentService(db).unlink_from_course(school_id, course_id, student_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
