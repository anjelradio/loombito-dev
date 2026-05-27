from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentParent(UUIDBaseModel, table=True):
    __tablename__ = "student_parent"
    __table_args__ = (
        Index(
            "uq_student_parent_pair_active",
            "user_id",
            "student_id",
            unique=True,
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
    )

    user_id: UUID = Field(foreign_key="user.id", index=True)
    student_id: UUID = Field(foreign_key="students.id", index=True)
