from datetime import datetime
from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentClusterRun(UUIDBaseModel, table=True):
    __tablename__ = "student_cluster_runs"
    __table_args__ = (
        Index(
            "uq_student_cluster_runs_active_context",
            "school_id",
            "assignment_id",
            "term_id",
            unique=True,
            sqlite_where=text("state = 1 AND is_active = 1"),
            postgresql_where=text("state = true AND is_active = true"),
        ),
    )

    school_id: UUID = Field(foreign_key="school.id", index=True)
    assignment_id: UUID = Field(foreign_key="assignments.id", index=True)
    term_id: UUID = Field(foreign_key="terms.id", index=True)
    trained_by_user_id: UUID | None = Field(default=None, foreign_key="user.id", index=True)

    status: str = Field(default="completed", min_length=3, max_length=20)
    features_version: str = Field(default="v1_2d_final_attendance", min_length=3, max_length=50)
    is_active: bool = Field(default=True, index=True)

    k_value: int = Field(ge=2, le=10)
    inertia: float = Field(ge=0)
    silhouette_score: float | None = Field(default=None)
    model_artifact_path: str | None = Field(default=None, max_length=500)
    trained_at: datetime = Field(default_factory=datetime.utcnow)


class StudentClusterResult(UUIDBaseModel, table=True):
    __tablename__ = "student_cluster_results"
    __table_args__ = (
        Index(
            "uq_student_cluster_results_run_student_active",
            "run_id",
            "student_id",
            unique=True,
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
    )

    run_id: UUID = Field(foreign_key="student_cluster_runs.id", index=True)
    student_id: UUID = Field(foreign_key="students.id", index=True)
    school_id: UUID = Field(foreign_key="school.id", index=True)

    cluster_id: int = Field(ge=0, le=20)
    cluster_label: str = Field(min_length=3, max_length=40)

    final_score: float = Field(ge=0, le=100)
    attendance_rate: float = Field(ge=0, le=100)
