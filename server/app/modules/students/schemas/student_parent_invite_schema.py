from datetime import datetime, timezone
from uuid import UUID

from pydantic import field_validator
from sqlmodel import SQLModel


class StudentInviteBulkExportRequest(SQLModel):
    expires_at: datetime
    max_uses: int

    @field_validator("expires_at")
    @classmethod
    def normalize_expires_at(cls, value: datetime) -> datetime:
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)

    @field_validator("max_uses")
    @classmethod
    def validate_max_uses(cls, value: int) -> int:
        if value < 1:
            raise ValueError("max_uses must be greater than or equal to 1")
        return value


class StudentJoinByCode(SQLModel):
    code: str

    @field_validator("code")
    @classmethod
    def normalize_code(cls, value: str) -> str:
        return value.strip().upper()


class StudentLinkedRead(SQLModel):
    id: UUID
    first_name: str
    last_name: str
    school_id: UUID
    school_name: str
    course_name: str | None = None

    model_config = {"from_attributes": True}


class StudentLinkedByUserRead(SQLModel):
    id: UUID
    first_name: str
    last_name: str
    school_id: UUID
    school_name: str
    course_name: str | None = None
