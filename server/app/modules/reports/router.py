from uuid import UUID

from fastapi import APIRouter, Query
from fastapi.responses import StreamingResponse
from io import BytesIO

from app.dependencies.auth import CurrentUser, DBSession
from app.modules.reports.schemas import (
    AttendanceReportGenerate,
    AttendanceReportGenerateRead,
    EvaluationReportGenerate,
    ReportCatalogItemRead,
    ReportRunRead,
    TermAverageReportGenerate,
)
from app.modules.reports.services import ReportService
from app.modules.reports.models import ReportType

router = APIRouter(prefix="/reports", tags=["Reportes"])


@router.get("/schools/{school_id}/catalog", response_model=list[ReportCatalogItemRead])
def get_report_catalog(school_id: UUID, db: DBSession, user: CurrentUser):
    return ReportService(db).get_catalog(school_id, user.id)


@router.get("/schools/{school_id}/runs", response_model=list[ReportRunRead])
def list_report_runs(
    school_id: UUID,
    db: DBSession,
    user: CurrentUser,
    report_type: ReportType | None = Query(default=None),
):
    return ReportService(db).list_runs(school_id, user.id, report_type)


@router.post(
    "/schools/{school_id}/generate/attendance",
    response_model=AttendanceReportGenerateRead,
)
def generate_attendance_report(
    school_id: UUID,
    db: DBSession,
    payload: AttendanceReportGenerate,
    user: CurrentUser,
):
    return ReportService(db).generate_attendance_report(school_id, payload, user.id)


@router.post("/schools/{school_id}/export/attendance")
def export_attendance_report(
    school_id: UUID,
    db: DBSession,
    payload: AttendanceReportGenerate,
    user: CurrentUser,
):
    content, file_name, media_type = ReportService(db).export_attendance_report_xlsx(school_id, payload, user.id)
    return StreamingResponse(
        BytesIO(content),
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{file_name}"'},
    )


@router.post("/schools/{school_id}/export/evaluation")
def export_evaluation_report(
    school_id: UUID,
    db: DBSession,
    payload: EvaluationReportGenerate,
    user: CurrentUser,
):
    content, file_name, media_type = ReportService(db).export_evaluation_report_xlsx(school_id, payload, user.id)
    return StreamingResponse(
        BytesIO(content),
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{file_name}"'},
    )


@router.post("/schools/{school_id}/export/term-average")
def export_term_average_report(
    school_id: UUID,
    db: DBSession,
    payload: TermAverageReportGenerate,
    user: CurrentUser,
):
    content, file_name = ReportService(db).export_term_average_report_xlsx(school_id, payload, user.id)
    return StreamingResponse(
        BytesIO(content),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{file_name}"'},
    )
