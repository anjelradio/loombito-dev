from datetime import datetime
from uuid import UUID

from sqlmodel import SQLModel


class PushTokenRegister(SQLModel):
    token: str
    platform: str = "android"


class PushTokenRead(SQLModel):
    id: UUID
    user_id: UUID
    token: str
    platform: str
    created_date: datetime

    model_config = {"from_attributes": True}
