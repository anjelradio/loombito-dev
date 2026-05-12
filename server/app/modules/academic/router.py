from uuid import UUID

from fastapi import APIRouter, Query, Response, status

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.academic.schemas import (
    AssignmentCourseGroupRead,
    AssignmentCourseOptionRead,
    AssignmentCreate,
    AssignmentSubjectOptionRead,
    AssignmentUpdate,
    AssignmentTeacherRead,
    CourseCreate,
    CourseFormOptionsRead,
    CourseRead,
    CourseUpdate,
    EvaluationWeightLevelRead,
    EvaluationWeightRead,
    EvaluationWeightUpsert,
    PaginatedCourse,
    PaginatedAssignmentTeacher,
    PaginatedSubject,
    TeacherAssignmentCourseRead,
    TeacherAssignmentCourseGroupRead,
    TeacherAssignmentSubjectRead,
    SubjectCreate,
    SubjectRead,
    SubjectUpdate,
    TermCreate,
    TermRead,
    TeacherAssignmentsRead,
    TermUpdate,
)
from app.modules.academic.services import (
    AssignmentService,
    CourseService,
    SubjectService,
    TeacherAssignmentContextService,
    TermService,
)

router = APIRouter(prefix="/academic", tags=["Academico"])


@router.get(
    "/schools/{school_id}/teacher/assignment-groups",
    response_model=list[TeacherAssignmentCourseGroupRead],
)
def list_teacher_assignment_groups(school_id: UUID, db: DBSession, actor: CurrentActor):
    return TeacherAssignmentContextService(db).list_teacher_assignment_groups(
        school_id, actor.user.id
    )


@router.get(
    "/schools/{school_id}/assignment-groups",
    response_model=list[TeacherAssignmentCourseGroupRead],
)
def list_assignment_groups_for_context(school_id: UUID, db: DBSession, actor: CurrentActor):
    return TeacherAssignmentContextService(db).list_assignment_groups_for_context(
        school_id, actor.user.id
    )


@router.get(
    "/schools/{school_id}/teacher/assignment-courses",
    response_model=list[TeacherAssignmentCourseRead],
)
def list_teacher_assignment_courses(school_id: UUID, db: DBSession, actor: CurrentActor):
    return TeacherAssignmentContextService(db).list_teacher_courses(school_id, actor.user.id)


@router.get(
    "/schools/{school_id}/teacher/assignment-courses/{course_id}/subjects",
    response_model=list[TeacherAssignmentSubjectRead],
)
def list_teacher_assignment_subjects_by_course(
    school_id: UUID,
    course_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return TeacherAssignmentContextService(db).list_teacher_subjects_by_course(
        school_id,
        course_id,
        actor.user.id,
    )


@router.get(
    "/schools/{school_id}/assignment-teachers",
    response_model=PaginatedAssignmentTeacher,
)
def list_assignment_teachers(
    school_id: UUID,
    db: DBSession,
    actor: CurrentActor,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
    search: str | None = Query(None, min_length=1, description="Busqueda por nombre"),
):
    return AssignmentService(db).list_teachers(school_id, actor.user.id, per_page, page, search)


@router.get(
    "/schools/{school_id}/assignment-course-options",
    response_model=list[AssignmentCourseOptionRead],
)
def list_assignment_course_options(school_id: UUID, db: DBSession, actor: CurrentActor):
    return AssignmentService(db).list_course_options(school_id, actor.user.id)


@router.get(
    "/schools/{school_id}/assignment-subject-options/{course_id}",
    response_model=list[AssignmentSubjectOptionRead],
)
def list_assignment_subject_options(
    school_id: UUID,
    course_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return AssignmentService(db).list_subject_options_by_course(
        school_id, course_id, actor.user.id
    )


@router.get(
    "/schools/{school_id}/teachers/{teacher_id}/assignments",
    response_model=TeacherAssignmentsRead,
)
def list_teacher_assignments(
    school_id: UUID,
    teacher_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return AssignmentService(db).list_teacher_assignments(
        school_id, teacher_id, actor.user.id
    )


@router.post(
    "/schools/{school_id}/teachers/{teacher_id}/assignments",
    response_model=TeacherAssignmentsRead,
)
def create_teacher_assignment(
    school_id: UUID,
    teacher_id: UUID,
    db: DBSession,
    payload: AssignmentCreate,
    actor: CurrentActor,
):
    return AssignmentService(db).create_for_teacher(school_id, teacher_id, payload, actor)


@router.put(
    "/schools/{school_id}/teachers/{teacher_id}/assignments/{course_id}",
    response_model=TeacherAssignmentsRead,
)
def replace_teacher_assignment_subjects(
    school_id: UUID,
    teacher_id: UUID,
    course_id: UUID,
    db: DBSession,
    payload: AssignmentUpdate,
    actor: CurrentActor,
):
    return AssignmentService(db).replace_teacher_course_subjects(
        school_id,
        teacher_id,
        course_id,
        payload,
        actor,
    )


@router.delete(
    "/schools/{school_id}/teachers/{teacher_id}/assignments/{course_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_teacher_assignments_by_course(
    school_id: UUID,
    teacher_id: UUID,
    course_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    AssignmentService(db).delete_teacher_course_assignments(
        school_id,
        teacher_id,
        course_id,
        actor,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/schools/{school_id}/subjects", response_model=SubjectRead)
def create_subject(
    school_id: UUID,
    db: DBSession,
    payload: SubjectCreate,
    actor: CurrentActor,
):
    return SubjectService(db).create(school_id, payload, actor)


@router.get("/schools/{school_id}/subjects", response_model=PaginatedSubject)
def list_subjects_by_school(
    school_id: UUID,
    db: DBSession,
    actor: CurrentActor,
    per_page: int = Query(5, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
    search: str | None = Query(None, min_length=1, description="Busqueda por nombre"),
):
    return SubjectService(db).list_by_school(
        school_id, actor.user.id, per_page, page, search
    )


@router.patch("/schools/{school_id}/subjects/{subject_id}", response_model=SubjectRead)
def update_subject(
    school_id: UUID,
    subject_id: UUID,
    db: DBSession,
    payload: SubjectUpdate,
    actor: CurrentActor,
):
    return SubjectService(db).update(school_id, subject_id, payload, actor)


@router.delete(
    "/schools/{school_id}/subjects/{subject_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_subject(
    school_id: UUID,
    subject_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    SubjectService(db).delete(school_id, subject_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/schools/{school_id}/course-form-options", response_model=CourseFormOptionsRead)
def get_course_form_options(school_id: UUID, db: DBSession, actor: CurrentActor):
    return CourseService(db).get_form_options(school_id, actor.user.id)


@router.post("/schools/{school_id}/courses", response_model=CourseRead)
def create_course(school_id: UUID, db: DBSession, payload: CourseCreate, actor: CurrentActor):
    return CourseService(db).create(school_id, payload, actor)


@router.put("/schools/{school_id}/courses/{course_id}", response_model=CourseRead)
def update_course(
    school_id: UUID,
    course_id: UUID,
    db: DBSession,
    payload: CourseUpdate,
    actor: CurrentActor,
):
    return CourseService(db).update(school_id, course_id, payload, actor)


@router.delete("/schools/{school_id}/courses/{course_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_course(school_id: UUID, course_id: UUID, db: DBSession, actor: CurrentActor):
    CourseService(db).delete(school_id, course_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/schools/{school_id}/courses", response_model=PaginatedCourse)
def list_courses_by_school(
    school_id: UUID,
    db: DBSession,
    actor: CurrentActor,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
    search: str | None = Query(None, min_length=1, description="Busqueda por nombre"),
):
    return CourseService(db).list_by_school(school_id, actor.user.id, per_page, page, search)


@router.get("/schools/{school_id}/courses/{course_id}", response_model=CourseRead)
def get_course_by_id(school_id: UUID, course_id: UUID, db: DBSession, actor: CurrentActor):
    return CourseService(db).get_by_id(school_id, course_id, actor.user.id)


@router.get("/schools/{school_id}/terms", response_model=list[TermRead])
def list_terms_by_school(school_id: UUID, db: DBSession, actor: CurrentActor):
    return TermService(db).list_terms(school_id, actor.user.id)


@router.post("/schools/{school_id}/terms", response_model=TermRead)
def create_term_by_school(
    school_id: UUID,
    db: DBSession,
    payload: TermCreate,
    actor: CurrentActor,
):
    return TermService(db).create_term(school_id, payload, actor)


@router.put("/schools/{school_id}/terms/{term_id}", response_model=TermRead)
def update_term_by_school(
    school_id: UUID,
    term_id: UUID,
    db: DBSession,
    payload: TermUpdate,
    actor: CurrentActor,
):
    return TermService(db).update_term(school_id, term_id, payload, actor)


@router.delete("/schools/{school_id}/terms/{term_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_term_by_school(school_id: UUID, term_id: UUID, db: DBSession, actor: CurrentActor):
    TermService(db).delete_term(school_id, term_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/schools/{school_id}/evaluation-weights",
    response_model=list[EvaluationWeightLevelRead],
)
def list_evaluation_weights_by_school(school_id: UUID, db: DBSession, actor: CurrentActor):
    return TermService(db).list_evaluation_weights(school_id, actor.user.id)


@router.put(
    "/schools/{school_id}/evaluation-weights/{school_level_id}",
    response_model=EvaluationWeightRead,
)
def upsert_evaluation_weight_by_school_level(
    school_id: UUID,
    school_level_id: UUID,
    db: DBSession,
    payload: EvaluationWeightUpsert,
    actor: CurrentActor,
):
    return TermService(db).upsert_evaluation_weight(
        school_id,
        school_level_id,
        payload,
        actor,
    )
