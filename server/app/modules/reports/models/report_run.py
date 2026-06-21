from enum import Enum
from typing import Any
from uuid import UUID

from sqlalchemy import JSON
from sqlmodel import Column, Field

from app.core.base_model import UUIDBaseModel


class ReportType(str, Enum):
    ATTENDANCE = "attendance_report"
    EVALUATION_GRADEBOOK = "evaluation_gradebook_report"
    TERM_AVERAGE = "term_average_report"
    CLUSTER_PERFORMANCE = "cluster_performance_report"
    BOLETIN = "boletin_report"


class ReportFormat(str, Enum):
    XLSX = "xlsx"
    PDF = "pdf"


class ReportRun(UUIDBaseModel, table=True):
    __tablename__ = "report_runs"

    school_id: UUID = Field(foreign_key="school.id", index=True)
    report_type: ReportType = Field(index=True)
    filters_json: dict[str, Any] = Field(default_factory=dict, sa_column=Column(JSON))
    columns_json: list[str] = Field(default_factory=list, sa_column=Column(JSON))
    format: ReportFormat = Field(default=ReportFormat.XLSX)
    summary: str | None = Field(default=None, max_length=500)
