import secrets
from math import ceil
from secrets import compare_digest
from uuid import UUID

from cryptography.fernet import Fernet, InvalidToken
from fastapi import HTTPException

from app.core.config import settings
from app.core.email import send_email
from app.core.otp import hash_otp
from app.core.redis import redis_client
from app.dependencies.auth import DBSession
from app.modules.auth.models import User
from app.modules.schools.models import SchoolRole
from app.modules.schools.repositories import SchoolUserRepository
from app.modules.system.models import AuditAction, AuditLog, AuditScope, AuditStatus
from app.modules.system.repositories import AuditRepository
from app.modules.system.schemas import (
    AuditLogRead,
    PaginatedAuditLog,
    RequestAuditAccessResponse,
    VerifyAuditAccessResponse,
)


class AuditService:
    def __init__(self, db: DBSession):
        self.db = db
        self.audit = AuditRepository(db)
        self.school_user = SchoolUserRepository(db)
        self._cipher = Fernet(settings.AUDIT_ENCRYPTION_KEY.encode("utf-8"))

    def _encrypt(self, plain_text: str) -> str:
        return self._cipher.encrypt(plain_text.encode("utf-8")).decode("utf-8")

    def _decrypt(self, cipher_text: str) -> str:
        try:
            return self._cipher.decrypt(cipher_text.encode("utf-8")).decode("utf-8")
        except InvalidToken:
            return "[No se pudo descifrar]"

    def _access_key(self, user_id: UUID) -> str:
        return f"audit_access_key:{user_id}"

    def _attempts_key(self, user_id: UUID) -> str:
        return f"audit_access_attempts:{user_id}"

    def _cooldown_key(self, user_id: UUID) -> str:
        return f"audit_access_cooldown:{user_id}"

    def _session_key(self, user_id: UUID) -> str:
        return f"audit_access_session:{user_id}"

    def _ensure_audit_session(self, user_id: UUID) -> None:
        active = redis_client.get(self._session_key(user_id))
        if not active:
            raise HTTPException(
                status_code=403,
                detail="Debes verificar la llave de acceso para ver la bitacora",
            )

    def _ensure_user_can_request_audit_access(self, user: User) -> None:
        if user.is_super_admin:
            return

        memberships = self.school_user.list_by_user(user.id)
        is_owner = any(membership.role == SchoolRole.OWNER for membership in memberships)
        if not is_owner:
            raise HTTPException(
                status_code=403,
                detail="Solo superadministrador u owner pueden acceder a la bitacora",
            )

    def _ensure_scope_permission(
        self, user: User, scope: AuditScope | None, school_id: UUID | None
    ) -> None:
        if user.is_super_admin:
            return

        if scope == AuditScope.SYSTEM:
            raise HTTPException(
                status_code=403,
                detail="Solo el superadministrador puede ver bitacora del sistema",
            )

        if not school_id:
            raise HTTPException(
                status_code=400,
                detail="Para este usuario se requiere school_id",
            )

        membership = self.school_user.get_by_user_and_school(user.id, school_id)
        if not membership or membership.role != SchoolRole.OWNER:
            raise HTTPException(
                status_code=403,
                detail="Solo el owner puede ver bitacora de esta escuela",
            )

    async def request_access_key(self, user: User) -> RequestAuditAccessResponse:
        self._ensure_user_can_request_audit_access(user)

        cooldown_ttl = redis_client.ttl(self._cooldown_key(user.id))
        if cooldown_ttl and cooldown_ttl > 0:
            raise HTTPException(
                status_code=429,
                detail=f"Debes esperar {cooldown_ttl} segundos para solicitar otra llave",
            )

        alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        access_key = "".join(
            secrets.choice(alphabet) for _ in range(settings.AUDIT_ACCESS_KEY_LENGTH)
        )
        access_key_hashed = hash_otp(access_key)
        access_ttl_seconds = settings.AUDIT_ACCESS_EXPIRES_MIN * 60

        html_content = (
            "<h2>Llave de acceso a bitacora</h2>"
            f"<p>Tu llave es: <strong>{access_key}</strong></p>"
            f"<p>Esta llave expira en {settings.AUDIT_ACCESS_EXPIRES_MIN} minutos.</p>"
        )

        try:
            await send_email(
                to_email=user.email,
                subject="Llave de acceso a bitacora",
                html_content=html_content,
            )
        except Exception:
            raise HTTPException(status_code=500, detail="No se pudo enviar la llave")

        redis_client.set(self._access_key(user.id), access_key_hashed, ex=access_ttl_seconds)
        redis_client.set(self._attempts_key(user.id), "0", ex=access_ttl_seconds)
        redis_client.set(
            self._cooldown_key(user.id), "1", ex=settings.OTP_RESEND_COOLDOWN_SEC
        )

        return RequestAuditAccessResponse(
            message="Se envio una llave de acceso a tu correo",
            expires_in_seconds=access_ttl_seconds,
        )

    def verify_access_key(self, user: User, access_key: str) -> VerifyAuditAccessResponse:
        self._ensure_user_can_request_audit_access(user)

        stored_hash = redis_client.get(self._access_key(user.id))
        if not stored_hash:
            raise HTTPException(status_code=400, detail="La llave expiro o no fue solicitada")

        attempts = int(redis_client.get(self._attempts_key(user.id)) or "0")
        if attempts >= settings.AUDIT_ACCESS_MAX_ATTEMPTS:
            raise HTTPException(
                status_code=429,
                detail="Se alcanzo el limite de intentos para la llave de acceso",
            )

        provided_hash = hash_otp(access_key.strip())
        if not compare_digest(stored_hash, provided_hash):
            attempts += 1
            remaining_ttl = redis_client.ttl(self._access_key(user.id))
            if remaining_ttl and remaining_ttl > 0:
                redis_client.set(self._attempts_key(user.id), str(attempts), ex=remaining_ttl)
            else:
                redis_client.set(self._attempts_key(user.id), str(attempts))

            if attempts >= settings.AUDIT_ACCESS_MAX_ATTEMPTS:
                raise HTTPException(
                    status_code=429,
                    detail="Se alcanzo el limite de intentos para la llave de acceso",
                )

            raise HTTPException(status_code=400, detail="Llave de acceso invalida")

        redis_client.delete(
            self._access_key(user.id),
            self._attempts_key(user.id),
            self._cooldown_key(user.id),
        )

        redis_client.set(
            self._session_key(user.id), "1", ex=settings.AUDIT_ACCESS_SESSION_SEC
        )

        return VerifyAuditAccessResponse(
            message="Llave verificada correctamente",
            session_expires_in_seconds=settings.AUDIT_ACCESS_SESSION_SEC,
        )

    def log_event(
        self,
        scope: AuditScope,
        action: AuditAction,
        status: AuditStatus,
        description: str,
        ip: str,
        actor_user_id: UUID | None = None,
        school_id: UUID | None = None,
        actor_identifier: str | None = None,
    ) -> AuditLog:
        resolved_actor_identifier = actor_identifier
        if not resolved_actor_identifier and actor_user_id:
            actor = self.db.get(User, actor_user_id)
            if actor:
                resolved_actor_identifier = actor.email

        audit_log = AuditLog(
            scope=scope,
            action=action,
            status=status,
            actor_user_id=actor_user_id,
            school_id=school_id,
            actor_identifier_enc=self._encrypt(resolved_actor_identifier)
            if resolved_actor_identifier
            else None,
            description_enc=self._encrypt(description),
            ip_enc=self._encrypt(ip),
        )
        self.audit.create(audit_log)
        self.db.commit()
        self.db.refresh(audit_log)
        return audit_log

    def list_logs(
        self,
        user: User,
        per_page: int,
        page: int,
        scope: AuditScope | None = None,
        school_id: UUID | None = None,
        action: AuditAction | None = None,
        status: AuditStatus | None = None,
    ) -> PaginatedAuditLog:
        self._ensure_audit_session(user.id)
        self._ensure_scope_permission(user, scope, school_id)

        total = self.audit.count_filtered(
            scope=scope,
            school_id=school_id,
            action=action,
            status=status,
        )
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        rows = (
            self.audit.list_filtered_paginated(
                per_page=per_page,
                page=current_page,
                scope=scope,
                school_id=school_id,
                action=action,
                status=status,
            )
            if total_pages > 0
            else []
        )

        return PaginatedAuditLog(
            logs=[
                AuditLogRead(
                    id=row.id,
                    created_date=row.created_date,
                    scope=row.scope,
                    action=row.action,
                    status=row.status,
                    actor_user_id=row.actor_user_id,
                    actor_identifier=self._decrypt(row.actor_identifier_enc)
                    if row.actor_identifier_enc
                    else None,
                    school_id=row.school_id,
                    description=self._decrypt(row.description_enc),
                    ip=self._decrypt(row.ip_enc),
                )
                for row in rows
            ],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )
