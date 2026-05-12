from uuid import UUID

from fastapi import APIRouter, Query

from app.dependencies.auth import CurrentUser, DBSession
from app.modules.system.models import AuditScope
from app.modules.system.schemas import (
    PaginatedAuditLog,
    RequestAuditAccessResponse,
    VerifyAuditAccessRequest,
    VerifyAuditAccessResponse,
)
from app.modules.system.services import AuditService

router = APIRouter(prefix="/system", tags=["Sistema"])


@router.post("/audit/access/request", response_model=RequestAuditAccessResponse)
async def request_audit_access_key(db: DBSession, user: CurrentUser):
    service = AuditService(db)
    return await service.request_access_key(user)


@router.post("/audit/access/verify", response_model=VerifyAuditAccessResponse)
def verify_audit_access_key(
    db: DBSession, payload: VerifyAuditAccessRequest, user: CurrentUser
):
    service = AuditService(db)
    return service.verify_access_key(user, payload.access_key)


@router.get("/audit/logs", response_model=PaginatedAuditLog)
def list_audit_logs(
    db: DBSession,
    user: CurrentUser,
    per_page: int = Query(default=8, ge=1, le=50),
    page: int = Query(default=1, ge=1),
    school_id: UUID | None = None,
):
    service = AuditService(db)
    return service.list_logs(
        user=user,
        per_page=per_page,
        page=page,
        scope=AuditScope.SYSTEM if not school_id else AuditScope.SCHOOL,
        school_id=school_id,
    )
