from uuid import UUID

from fastapi import APIRouter, Query, Response, status

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.attendance.schemas import (
    AttendanceFinalizeSummaryRead,
    AttendanceGradebookRowRead,
    AttendanceRecordUpsert,
    AttendanceSessionCreate,
    AttendanceSessionRead,
    AttendanceStatusRead,
    PaginatedAttendanceSession,
)
from app.modules.attendance.services import AttendanceService

router = APIRouter(prefix="/attendance", tags=["Asistencias"])


@router.get("/schools/{school_id}/status-options", response_model=list[AttendanceStatusRead])
def list_attendance_status_options(school_id: UUID, db: DBSession, actor: CurrentActor):
    return AttendanceService(db).list_status_options(school_id, actor.user.id)


@router.post("/schools/{school_id}/sessions", response_model=AttendanceSessionRead)
def create_attendance_session(
    school_id: UUID,
    db: DBSession,
    payload: AttendanceSessionCreate,
    actor: CurrentActor,
):
    return AttendanceService(db).create_session(school_id, payload, actor)


@router.get(
    "/schools/{school_id}/assignments/{assignment_id}/sessions",
    response_model=PaginatedAttendanceSession,
)
def list_attendance_sessions_by_assignment(
    school_id: UUID,
    assignment_id: UUID,
    db: DBSession,
    actor: CurrentActor,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
):
    return AttendanceService(db).list_sessions_by_assignment(
        school_id,
        assignment_id,
        actor.user.id,
        per_page,
        page,
    )


@router.get("/schools/{school_id}/sessions/{session_id}", response_model=AttendanceSessionRead)
def get_attendance_session_by_id(
    school_id: UUID,
    session_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return AttendanceService(db).get_session_by_id(school_id, session_id, actor.user.id)


@router.delete("/schools/{school_id}/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_attendance_session(
    school_id: UUID,
    session_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    AttendanceService(db).delete_session(school_id, session_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/schools/{school_id}/sessions/{session_id}/gradebook",
    response_model=list[AttendanceGradebookRowRead],
)
def list_attendance_gradebook_by_session(
    school_id: UUID,
    session_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return AttendanceService(db).list_gradebook_by_session(school_id, session_id, actor.user.id)


@router.put(
    "/schools/{school_id}/sessions/{session_id}/students/{student_id}/record",
    response_model=AttendanceGradebookRowRead,
)
def upsert_attendance_record(
    school_id: UUID,
    session_id: UUID,
    student_id: UUID,
    db: DBSession,
    payload: AttendanceRecordUpsert,
    actor: CurrentActor,
):
    return AttendanceService(db).upsert_record(
        school_id,
        session_id,
        student_id,
        payload,
        actor,
    )


@router.post(
    "/schools/{school_id}/sessions/{session_id}/finalize",
    response_model=AttendanceFinalizeSummaryRead,
)
def finalize_attendance_session(
    school_id: UUID,
    session_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return AttendanceService(db).finalize_session(school_id, session_id, actor)
