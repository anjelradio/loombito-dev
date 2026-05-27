from datetime import date
from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentLicense(UUIDBaseModel, table=True):
    __tablename__ = "student_licenses"
    __table_args__ = (
        Index(
            "ix_student_licenses_student_created",
            "student_id",
            "created_date",
        ),
        Index(
            "ix_student_licenses_school_created",
            "school_id",
            "created_date",
        ),
        Index(
            "ix_student_licenses_student_active",
            "student_id",
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
    )

    school_id: UUID = Field(foreign_key="school.id", index=True)
    student_id: UUID = Field(foreign_key="students.id", index=True)
    author_user_id: UUID = Field(foreign_key="user.id", index=True)

    reason: str = Field(index=True, min_length=3, max_length=40)
    description: str = Field(min_length=3, max_length=1200)
    start_date: date
    end_date: date
