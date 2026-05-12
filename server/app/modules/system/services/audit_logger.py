from uuid import UUID

from app.dependencies.auth import DBSession
from app.modules.system.models import AuditAction, AuditScope, AuditStatus
from app.modules.system.services.audit_service import AuditService


class AuditLogger:
    def __init__(self, db: DBSession):
        self.db = db
        self.audit = AuditService(db)

    def safe_log(
        self,
        action: AuditAction,
        status: AuditStatus,
        description: str,
        ip: str,
        scope: AuditScope = AuditScope.SYSTEM,
        actor_user_id: UUID | None = None,
        school_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        try:
            self.audit.log_event(
                scope=scope,
                action=action,
                status=status,
                description=description,
                ip=ip,
                actor_user_id=actor_user_id,
                school_id=school_id,
                actor_identifier=actor_identifier,
            )
        except Exception:
            self.db.rollback()

    def safe_log_system(
        self,
        action: AuditAction,
        status: AuditStatus,
        description: str,
        ip: str,
        actor_user_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        self.safe_log(
            action=action,
            status=status,
            description=description,
            ip=ip,
            scope=AuditScope.SYSTEM,
            actor_user_id=actor_user_id,
            actor_identifier=actor_identifier,
        )

    def safe_log_school(
        self,
        action: AuditAction,
        status: AuditStatus,
        description: str,
        ip: str,
        school_id: UUID,
        actor_user_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        self.safe_log(
            action=action,
            status=status,
            description=description,
            ip=ip,
            scope=AuditScope.SCHOOL,
            actor_user_id=actor_user_id,
            school_id=school_id,
            actor_identifier=actor_identifier,
        )

    def safe_log_system_success(
        self,
        action: AuditAction,
        description: str,
        ip: str,
        actor_user_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        self.safe_log_system(
            action=action,
            status=AuditStatus.SUCCESS,
            description=description,
            ip=ip,
            actor_user_id=actor_user_id,
            actor_identifier=actor_identifier,
        )

    def safe_log_system_failed(
        self,
        action: AuditAction,
        description: str,
        ip: str,
        actor_user_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        self.safe_log_system(
            action=action,
            status=AuditStatus.FAILED,
            description=description,
            ip=ip,
            actor_user_id=actor_user_id,
            actor_identifier=actor_identifier,
        )

    def safe_log_school_success(
        self,
        action: AuditAction,
        description: str,
        ip: str,
        school_id: UUID,
        actor_user_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        self.safe_log_school(
            action=action,
            status=AuditStatus.SUCCESS,
            description=description,
            ip=ip,
            school_id=school_id,
            actor_user_id=actor_user_id,
            actor_identifier=actor_identifier,
        )

    def safe_log_school_failed(
        self,
        action: AuditAction,
        description: str,
        ip: str,
        school_id: UUID,
        actor_user_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> None:
        self.safe_log_school(
            action=action,
            status=AuditStatus.FAILED,
            description=description,
            ip=ip,
            school_id=school_id,
            actor_user_id=actor_user_id,
            actor_identifier=actor_identifier,
        )
