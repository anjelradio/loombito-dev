from datetime import date, datetime
from typing import Any
from uuid import UUID

from sqlmodel import SQLModel

from app.modules.reports.models import ReportFormat, ReportType


class ReportCatalogItemRead(SQLModel):
    report_type: ReportType
    label: str
    allowed_filters: list[str]
    allowed_columns: list[str]
    allowed_formats: list[ReportFormat]


class ReportRunRead(SQLModel):
    id: UUID
    school_id: UUID
    report_type: ReportType
    filters_json: dict[str, Any]
    columns_json: list[str]
    format: ReportFormat
    summary: str | None
    created_date: datetime


class AttendanceReportGenerate(SQLModel):
    assignment_id: UUID
    from_date: date | None = None
    to_date: date | None = None
    mode: str = "general"
    student_id: UUID | None = None
    student_last_name: str | None = None
    student_first_name: str | None = None
    attendance_status_filter: str | None = None
    columns: list[str]
    format: ReportFormat = ReportFormat.XLSX
    summary: str | None = None


class AttendanceReportPreviewRow(SQLModel):
    attendance_date: str | None = None
    session_name: str | None = None
    course_name: str | None = None
    subject_name: str | None = None
    student_last_name: str | None = None
    student_first_name: str | None = None
    status_name: str | None = None
    observation: str | None = None


class AttendanceReportGenerateRead(SQLModel):
    run: ReportRunRead
    rows: list[AttendanceReportPreviewRow]


class EvaluationReportGenerate(SQLModel):
    assignment_id: UUID | None = None
    evaluation_id: UUID | None = None
    columns: list[str]
    format: ReportFormat = ReportFormat.XLSX
    summary: str | None = None


class TermAverageReportGenerate(SQLModel):
    assignment_id: UUID
    term_id: UUID
    columns: list[str]
    format: ReportFormat = ReportFormat.XLSX
    summary: str | None = None

class BoletinReportGenerate(SQLModel):
    course_id: UUID
    student_id: UUID
    format: ReportFormat = ReportFormat.PDF
    summary: str | None = None
