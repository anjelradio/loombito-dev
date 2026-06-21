from datetime import datetime
from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentRiskPrediction(UUIDBaseModel, table=True):
    __tablename__ = "student_risk_predictions"
    __table_args__ = (
        Index(
            "uq_student_risk_predictions_active",
            "school_id",
            "assignment_id",
            "term_id",
            "student_id",
            unique=True,
            sqlite_where=text("state = 1 AND is_active = 1"),
            postgresql_where=text("state = true AND is_active = true"),
        ),
    )

    school_id: UUID = Field(foreign_key="school.id", index=True)
    assignment_id: UUID = Field(foreign_key="assignments.id", index=True)
    term_id: UUID = Field(foreign_key="terms.id", index=True)
    student_id: UUID = Field(foreign_key="students.id", index=True)

    projected_final_score: float = Field(ge=0, le=100)
    failure_probability: float = Field(ge=0.0, le=1.0)
    
    is_active: bool = Field(default=True, index=True)
    calculated_at: datetime = Field(default_factory=datetime.utcnow)
