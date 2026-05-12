from enum import Enum
from uuid import UUID

from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class AuditScope(str, Enum):
    SYSTEM = "system"
    SCHOOL = "school"


class AuditAction(str, Enum):
    LOGIN = "login"
    LOGOUT = "logout"
    REGISTER = "register"
    JOIN = "join"
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"
    ACCESS = "access"
    INVITE = "invite"
    ROLE_CHANGE = "role_change"


class AuditStatus(str, Enum):
    SUCCESS = "success"
    FAILED = "failed"


class AuditLog(UUIDBaseModel, table=True):
    __tablename__ = "audit_logs"

    scope: AuditScope = Field(index=True)
    action: AuditAction = Field(index=True)
    status: AuditStatus = Field(index=True)

    actor_user_id: UUID | None = Field(default=None, foreign_key="user.id", index=True)
    school_id: UUID | None = Field(default=None, foreign_key="school.id", index=True)
    actor_identifier_enc: str | None = Field(default=None, max_length=500)

    description_enc: str = Field(max_length=2000)
    ip_enc: str = Field(max_length=500)
