from datetime import date, datetime
from uuid import UUID

from sqlmodel import SQLModel


class StudentLicenseReason:
    ILLNESS = "illness"
    TRAVEL = "travel"
    PERSONAL = "personal"

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return (cls.ILLNESS, cls.TRAVEL, cls.PERSONAL)


class StudentLicenseCreate(SQLModel):
    reason: str
    description: str
    start_date: date
    end_date: date


class StudentLicenseRead(SQLModel):
    id: UUID
    school_id: UUID
    student_id: UUID
    author_user_id: UUID
    reason: str
    description: str
    start_date: date
    end_date: date
    created_date: datetime

    model_config = {"from_attributes": True}
