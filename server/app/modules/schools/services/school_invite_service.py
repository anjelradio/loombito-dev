from datetime import datetime, timezone
from secrets import choice
from string import ascii_uppercase, digits
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.schools.models import InviteRole, SchoolInvite, SchoolRole, SchoolUser
from app.modules.schools.permissions import ensure_owner
from app.modules.schools.repositories import (
    SchoolInviteRepository,
    SchoolRepository,
    SchoolUserRepository,
)
from app.modules.schools.schemas import (
    InviteStatus,
    SchoolInviteCreate,
    SchoolInviteRead,
    SchoolJoinByCode,
    SchoolWithRole,
)
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class SchoolInviteService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.invite = SchoolInviteRepository(db)
        self.audit_logger = AuditLogger(db)

    def _generate_unique_code(self, role: InviteRole) -> str:
        alphabet = ascii_uppercase + digits
        prefix = "T" if role == InviteRole.TEACHER else "A"

        for _ in range(30):
            code = prefix + "".join(choice(alphabet) for _ in range(5))
            if not self.invite.get_active_by_code(code):
                return code

        raise HTTPException(
            status_code=500,
            detail="No se pudo generar un codigo unico",
        )

    def _is_expired(self, expires_at: datetime) -> bool:
        normalized_expires_at = (
            expires_at.replace(tzinfo=timezone.utc)
            if expires_at.tzinfo is None
            else expires_at.astimezone(timezone.utc)
        )
        return normalized_expires_at <= datetime.now(timezone.utc)

    def _to_read(self, invite: SchoolInvite) -> SchoolInviteRead:
        status = InviteStatus.EXPIRED if self._is_expired(invite.expires_at) else InviteStatus.ACTIVE
        return SchoolInviteRead(
            id=invite.id,
            code=invite.code,
            role=invite.role,
            created_date=invite.created_date,
            expires_at=invite.expires_at,
            school_id=invite.school_id,
            status=status,
        )

    def create(self, school_id: UUID, payload: SchoolInviteCreate, actor: CurrentActorContext):
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_owner(self.school_user, actor.user.id, school_id)

        if self._is_expired(payload.expires_at):
            raise HTTPException(
                status_code=400,
                detail="La fecha de expiracion debe ser futura",
            )

        for _ in range(8):
            try:
                existing_invite = self.invite.get_active_by_school_and_role(
                    school_id, payload.role
                )
                if existing_invite:
                    self.invite.delete(existing_invite)
                    self.db.flush()

                new_invite = SchoolInvite(
                    code=self._generate_unique_code(payload.role),
                    role=InviteRole(payload.role),
                    expires_at=payload.expires_at,
                    school_id=school_id,
                )
                self.invite.create(new_invite)
                self.db.flush()
                self.db.commit()
                self.db.refresh(new_invite)
                self.audit_logger.safe_log_school_success(
                    action=AuditAction.INVITE,
                    description="Creacion de invitacion de escuela exitosa",
                    ip=actor.ip,
                    school_id=school_id,
                    actor_user_id=actor.user.id,
                )
                return self._to_read(new_invite)
            except IntegrityError:
                self.db.rollback()

        raise HTTPException(
            status_code=500,
            detail="No se pudo generar un codigo unico",
        )

    def list_by_school(self, school_id: UUID, actor: CurrentActorContext) -> list[SchoolInviteRead]:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_owner(self.school_user, actor.user.id, school_id)

        invites = self.invite.list_active_by_school(school_id)
        return [self._to_read(invite) for invite in invites]

    def delete(self, school_id: UUID, invite_id: UUID, actor: CurrentActorContext) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_owner(self.school_user, actor.user.id, school_id)

        invite = self.invite.get_active_by_id(invite_id)
        if not invite or invite.school_id != school_id:
            raise HTTPException(status_code=404, detail="Invitacion no encontrada")

        self.invite.delete(invite)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de invitacion de escuela exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    def join_by_code(self, payload: SchoolJoinByCode, actor: CurrentActorContext) -> SchoolWithRole:
        invite = self.invite.get_active_by_code(payload.code)
        if not invite:
            raise HTTPException(status_code=404, detail="El codigo no existe o expiro")

        if self._is_expired(invite.expires_at):
            raise HTTPException(status_code=404, detail="El codigo no existe o expiro")

        school = self.school.get(invite.school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        target_role = SchoolRole(invite.role)
        existing_membership = self.school_user.get_by_user_school_and_role(
            actor.user.id, invite.school_id, target_role
        )
        if existing_membership:
            raise HTTPException(
                status_code=409,
                detail="Ya te encuentras en esta escuela con ese rol",
            )

        link = SchoolUser(
            user_id=actor.user.id, school_id=invite.school_id, role=target_role
        )

        try:
            self.school_user.create(link)
            self.db.commit()
            self.audit_logger.safe_log_school_success(
                action=AuditAction.JOIN,
                description="Union a escuela por codigo exitosa",
                ip=actor.ip,
                school_id=invite.school_id,
                actor_user_id=actor.user.id,
            )
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=409,
                detail="Ya te encuentras en esta escuela con ese rol",
            )

        return SchoolWithRole(
            id=school.id,
            name=school.name,
            logo_image=school.logo_image,
            type=school.type,
            phone=school.phone,
            role=target_role,
        )
