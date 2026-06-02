from uuid import UUID

from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class PushToken(UUIDBaseModel, table=True):
    __tablename__ = "push_tokens"

    user_id: UUID = Field(foreign_key="user.id", index=True)
    token: str = Field(index=True, unique=True, max_length=255)
    platform: str = Field(default="android", max_length=20)
