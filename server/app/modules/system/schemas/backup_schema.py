from datetime import datetime
from uuid import UUID

from sqlmodel import SQLModel


class SchoolBackupRead(SQLModel):
    id: UUID
    school_id: UUID
    created_by_user_id: UUID
    file_name: str
    file_size_bytes: int
    checksum_sha256: str
    status: str
    created_date: datetime
    restored_date: datetime | None


class CreateSchoolBackupResponse(SQLModel):
    backup: SchoolBackupRead


class RestoreSchoolBackupPayload(SQLModel):
    confirm_text: str


class RestoreSchoolBackupResponse(SQLModel):
    backup_id: UUID
    restored: bool
    restored_date: datetime


class DeleteSchoolBackupResponse(SQLModel):
    backup_id: UUID
    deleted: bool
