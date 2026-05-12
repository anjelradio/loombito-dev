import string
from random import SystemRandom
from secrets import choice, compare_digest

from fastapi import HTTPException

from app.core.config import settings
from app.core.email import send_email
from app.core.otp import generate_otp, hash_otp
from app.core.redis import redis_client
from app.core.security import hash_password
from app.core.validators import validate_password_policy
from app.dependencies.auth import DBSession, RequestActor
from app.modules.auth.repositories import UserRepository
from app.modules.auth.schemas import (
    RequestPasswordResetOtpRequest,
    RequestPasswordResetOtpResponse,
    VerifyPasswordResetOtpRequest,
    VerifyPasswordResetOtpResponse,
)
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger

secure_random = SystemRandom()


class PasswordResetService:
    def __init__(self, db: DBSession):
        self.repo = UserRepository(db)
        self.audit_logger = AuditLogger(db)

    def _generate_temporary_password(self, length: int = 10) -> str:
        generated = [choice(string.ascii_uppercase) for _ in range(2)]
        generated.extend(choice(string.digits) for _ in range(2))

        pool = string.ascii_letters + string.digits
        for _ in range(max(length - 4, 4)):
            generated.append(choice(pool))

        secure_random.shuffle(generated)
        return "".join(generated)

    async def request_password_reset_otp(
        self,
        payload: RequestPasswordResetOtpRequest,
        actor: RequestActor,
    ) -> RequestPasswordResetOtpResponse:
        email = str(payload.email).strip().lower()
        user = self.repo.get_by_email(email)

        otp_key = f"password_reset_otp:{email}"
        attempts_key = f"password_reset_otp_attempts:{email}"
        cooldown_key = f"password_reset_otp_cooldown:{email}"

        ttl = redis_client.ttl(cooldown_key)
        if ttl and ttl > 0:
            raise HTTPException(
                status_code=429,
                detail=f"Debes esperar {ttl} segundos para solicitar otro codigo",
            )

        otp_ttl_seconds = settings.OTP_EXPIRES_MIN * 60

        if user:
            otp = generate_otp()
            otp_hashed = hash_otp(otp)

            html_content = (
                f"<h2>Recuperacion de contraseña</h2>"
                f"<p>Tu codigo OTP es: <strong>{otp}</strong></p>"
                f"<p>Este codigo expira en {settings.OTP_EXPIRES_MIN} minutos.</p>"
            )

            try:
                await send_email(
                    to_email=user.email,
                    subject="Codigo OTP para recuperar contraseña",
                    html_content=html_content,
                )
            except Exception:
                raise HTTPException(
                    status_code=500, detail="No se pudo enviar el codigo OTP"
                )

            redis_client.set(otp_key, otp_hashed, ex=otp_ttl_seconds)
            redis_client.set(attempts_key, "0", ex=otp_ttl_seconds)

        redis_client.set(cooldown_key, "1", ex=settings.OTP_RESEND_COOLDOWN_SEC)

        result = RequestPasswordResetOtpResponse(
            message="Si el correo existe, se envio un codigo OTP",
            expires_in_seconds=otp_ttl_seconds,
        )
        self.audit_logger.safe_log_system_success(
            action=AuditAction.ACCESS,
            description="Solicitud exitosa de OTP para recuperacion de contraseña",
            ip=actor.ip,
            actor_user_id=user.id if user else None,
        )
        return result

    async def verify_password_reset_otp(
        self,
        payload: VerifyPasswordResetOtpRequest,
        actor: RequestActor,
    ) -> VerifyPasswordResetOtpResponse:
        email = str(payload.email).strip().lower()
        user = self.repo.get_by_email(email)
        if not user:
            raise HTTPException(status_code=400, detail="Codigo OTP invalido o expirado")

        otp_key = f"password_reset_otp:{email}"
        attempts_key = f"password_reset_otp_attempts:{email}"
        cooldown_key = f"password_reset_otp_cooldown:{email}"

        stored_otp_hash = redis_client.get(otp_key)
        if not stored_otp_hash:
            raise HTTPException(status_code=400, detail="Codigo OTP invalido o expirado")

        attempts = int(redis_client.get(attempts_key) or "0")
        if attempts >= settings.OTP_MAX_ATTEMPTS:
            raise HTTPException(
                status_code=429,
                detail="Se alcanzo el limite de intentos para el codigo OTP",
            )

        provided_otp_hash = hash_otp(payload.otp.strip())
        if not compare_digest(stored_otp_hash, provided_otp_hash):
            attempts += 1
            remaining_ttl = redis_client.ttl(otp_key)

            if remaining_ttl and remaining_ttl > 0:
                redis_client.set(attempts_key, str(attempts), ex=remaining_ttl)
            else:
                redis_client.set(attempts_key, str(attempts))

            if attempts >= settings.OTP_MAX_ATTEMPTS:
                raise HTTPException(
                    status_code=429,
                    detail="Se alcanzo el limite de intentos para el codigo OTP",
                )

            raise HTTPException(status_code=400, detail="Codigo OTP invalido o expirado")

        redis_client.delete(otp_key, attempts_key, cooldown_key)

        temporary_password = self._generate_temporary_password()
        validate_password_policy(temporary_password)

        html_content = (
            f"<h2>Nueva contraseña temporal</h2>"
            f"<p>Tu nueva contraseña es: <strong>{temporary_password}</strong></p>"
            f"<p>Por seguridad, cambiala desde tu perfil despues de iniciar sesion.</p>"
        )

        try:
            await send_email(
                to_email=user.email,
                subject="Nueva contraseña temporal",
                html_content=html_content,
            )
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="No se pudo enviar la nueva contraseña al correo",
            )

        user.hashed_password = hash_password(temporary_password)
        self.repo.update(user)

        result = VerifyPasswordResetOtpResponse(
            message="Se envio una nueva contraseña a tu correo"
        )
        self.audit_logger.safe_log_system_success(
            action=AuditAction.UPDATE,
            description="Restablecimiento exitoso de contraseña con OTP",
            ip=actor.ip,
            actor_user_id=user.id,
        )
        return result
