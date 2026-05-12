from datetime import datetime
from uuid import UUID

from sqlmodel import SQLModel


class StudentClusterRowRead(SQLModel):
    student_id: UUID
    first_name: str
    last_name: str
    cluster_id: int
    cluster_label: str
    final_score: float
    attendance_rate: float


class StudentClusterSnapshotRead(SQLModel):
    assignment_id: UUID
    term_id: UUID
    school_id: UUID
    features_version: str | None
    k_value: int | None
    inertia: float | None
    silhouette_score: float | None
    trained_at: datetime | None
    students: list[StudentClusterRowRead]


class StudentClusterRecalculateSummaryRead(SQLModel):
    assignment_id: UUID
    term_id: UUID
    school_id: UUID
    run_id: UUID
    processed_students: int
    k_value: int
    inertia: float
    silhouette_score: float | None
    trained_at: datetime
