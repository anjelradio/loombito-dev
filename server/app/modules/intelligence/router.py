from uuid import UUID
from io import BytesIO

from fastapi import APIRouter, File, HTTPException, Query, UploadFile
from fastapi.responses import StreamingResponse

from app.dependencies.auth import CurrentActor, CurrentUser, DBSession
from app.modules.reports.models import ReportFormat
from app.modules.reports.schemas import AttendanceReportGenerate
from app.modules.reports.services import ReportService
from app.modules.intelligence.schemas import (
    StudentClusterRecalculateSummaryRead,
    StudentClusterSnapshotRead,
    StudentStatisticsResponse,
)
from app.modules.intelligence.services import AttendanceAudioInterpreterService, StudentClusterService, StudentStatisticsService
from app.modules.intelligence.services.regressions.student_risk_service import StudentRiskService
from app.core.config import settings
from fastapi import Header, status

router = APIRouter(prefix="/intelligence", tags=["Intelligence"])

@router.get(
    "/schools/{school_id}/students/{student_id}/statistics",
    response_model=StudentStatisticsResponse,
)
def get_student_performance_statistics(
    school_id: UUID,
    student_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    service = StudentStatisticsService(db)
    return service.get_student_statistics(school_id, student_id, actor.user.id)

@router.post(
    "/cron/recalculate-all",
    status_code=status.HTTP_200_OK,
    tags=["Cron Jobs"],
)
def cron_recalculate_all_intelligence(db: DBSession, authorization: str | None = Header(None)):
    """
    Endpoint intended to be called by a CRON job (e.g. cron-job.org).
    Validates a secret token.
    """
    secret = settings.JWT_SECRET
    expected_token = f"Bearer {secret}"
    
    if authorization != expected_token:
        raise HTTPException(status_code=401, detail="Unauthorized CRON caller")
    
    service = StudentRiskService(db)
    result = service.recalculate_all_global()
    return {"message": "Global intelligence recalculation completed", "data": result}


@router.get(
    "/schools/{school_id}/assignments/{assignment_id}/terms/{term_id}/clusters",
    response_model=StudentClusterSnapshotRead,
)
def get_student_clusters_snapshot(
    school_id: UUID,
    assignment_id: UUID,
    term_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return StudentClusterService(db).get_snapshot(school_id, assignment_id, term_id, actor.user.id)


@router.post(
    "/schools/{school_id}/assignments/{assignment_id}/terms/{term_id}/clusters/recalculate",
    response_model=StudentClusterRecalculateSummaryRead,
)
def recalculate_student_clusters(
    school_id: UUID,
    assignment_id: UUID,
    term_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return StudentClusterService(db).recalculate(school_id, assignment_id, term_id, actor.user.id)


@router.post("/schools/{school_id}/assignments/{assignment_id}/attendance-reports/export-from-audio")
async def export_attendance_report_from_audio(
    school_id: UUID,
    assignment_id: UUID,
    db: DBSession,
    user: CurrentUser,
    audio: UploadFile = File(...),
    format: ReportFormat = Query(default=ReportFormat.XLSX),
):
    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(status_code=400, detail="El audio no contiene datos")
    parsed = AttendanceAudioInterpreterService().parse_to_attendance_filters(
        audio_bytes,
        audio.content_type or "audio/webm",
    )

    payload = AttendanceReportGenerate(
        assignment_id=assignment_id,
        from_date=parsed.get("from_date"),
        to_date=parsed.get("to_date"),
        mode="student_specific",
        student_last_name=parsed.get("student_last_name"),
        student_first_name=parsed.get("student_first_name"),
        attendance_status_filter=parsed.get("attendance_status_filter"),
        columns=parsed.get("columns") or [
            "student_last_name",
            "student_first_name",
            "attendance_date",
            "status_name",
            "observation",
        ],
        format=format,
        summary=parsed.get("summary"),
    )

    content, file_name, media_type = ReportService(db).export_attendance_report_xlsx(
        school_id,
        payload,
        user.id,
    )
    return StreamingResponse(
        BytesIO(content),
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{file_name}"'},
    )
