from datetime import datetime
from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class Notification(UUIDBaseModel, table=True):
    __tablename__ = "notification"
    __table_args__ = (
        Index(
            "ix_notification_recipient_unread_created",
            "recipient_user_id",
            "is_read",
            "created_date",
        ),
        Index(
            "ix_notification_student_created",
            "student_id",
            "created_date",
        ),
        Index(
            "ix_notification_recipient_active",
            "recipient_user_id",
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
    )

    recipient_user_id: UUID = Field(foreign_key="user.id", index=True)
    school_id: UUID = Field(foreign_key="school.id", index=True)
    student_id: UUID = Field(foreign_key="students.id", index=True)
    title: str
    body: str
    is_read: bool = Field(default=False, index=True)
    read_at: datetime | None = None
