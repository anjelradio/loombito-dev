from uuid import UUID

from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentCommunication(UUIDBaseModel, table=True):
    __tablename__ = "student_communication"

    school_id: UUID = Field(foreign_key="school.id", index=True)
    student_id: UUID = Field(foreign_key="students.id", index=True)
    author_user_id: UUID = Field(foreign_key="user.id", index=True)
    title: str
    body: str
