from uuid import UUID

from sqlmodel import Session, select

from app.modules.reports.models import ReportRun, ReportType


class ReportRunRepository:
    def __init__(self, db: Session):
        self.db = db

    # Lista historial activo de reportes por escuela.
    def list_active_by_school_id(self, school_id: UUID, report_type: ReportType | None = None) -> list[ReportRun]:
        query = select(ReportRun).where(ReportRun.school_id == school_id, ReportRun.state == True)
        if report_type:
            query = query.where(ReportRun.report_type == report_type)
        query = query.order_by(ReportRun.created_date.desc())
        return self.db.exec(query).all()

    # Persiste un nuevo registro de ejecucion de reporte.
    def create(self, report_run: ReportRun) -> ReportRun:
        self.db.add(report_run)
        return report_run
