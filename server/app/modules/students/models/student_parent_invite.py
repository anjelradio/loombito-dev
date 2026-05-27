from datetime import datetime
from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentParentInvite(UUIDBaseModel, table=True):
    __tablename__ = "student_parent_invite"
    __table_args__ = (
        Index(
            "uq_student_parent_invite_code_active",
            "code",
            unique=True,
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
        Index(
            "uq_student_parent_invite_student_active",
            "student_id",
            unique=True,
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
    )

    code: str = Field(index=True)
    expires_at: datetime
    max_uses: int = Field(default=1, ge=1)
    used_count: int = Field(default=0, ge=0)
    student_id: UUID = Field(foreign_key="students.id", index=True)
