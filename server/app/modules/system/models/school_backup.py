from datetime import datetime
from uuid import UUID

from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class SchoolBackup(UUIDBaseModel, table=True):
    __tablename__ = "school_backups"

    school_id: UUID = Field(foreign_key="school.id", index=True)
    created_by_user_id: UUID = Field(foreign_key="user.id", index=True)

    file_name: str = Field(max_length=255)
    file_path: str = Field(max_length=1000)
    file_size_bytes: int = Field(default=0)
    checksum_sha256: str = Field(max_length=128)

    status: str = Field(default="created", max_length=30)
    restored_date: datetime | None = Field(default=None)
