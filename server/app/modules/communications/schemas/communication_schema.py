from datetime import datetime
from uuid import UUID

from sqlmodel import SQLModel


class StudentCommunicationCreate(SQLModel):
    title: str
    body: str


class StudentCommunicationUpdate(SQLModel):
    title: str
    body: str


class StudentCommunicationRead(SQLModel):
    id: UUID
    school_id: UUID
    student_id: UUID
    author_user_id: UUID
    title: str
    body: str
    created_date: datetime

    model_config = {"from_attributes": True}


class NotificationRead(SQLModel):
    id: UUID
    recipient_user_id: UUID
    school_id: UUID
    student_id: UUID
    title: str
    body: str
    is_read: bool
    read_at: datetime | None
    created_date: datetime

    model_config = {"from_attributes": True}


class TeacherCommunicationCourseRead(SQLModel):
    id: UUID
    name: str


class TeacherCommunicationCourseStudentRead(SQLModel):
    id: UUID
    first_name: str
    last_name: str
