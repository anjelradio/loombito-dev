from uuid import UUID

from fastapi import APIRouter, HTTPException, Query

from app.dependencies.auth import CurrentUser, DBSession
from app.modules.system.models import AuditScope
from app.modules.system.schemas import (
    CreateSchoolBackupResponse,
    DeleteSchoolBackupResponse,
    PaginatedAuditLog,
    RequestAuditAccessResponse,
    RestoreSchoolBackupPayload,
    RestoreSchoolBackupResponse,
    SchoolBackupRead,
    VerifyAuditAccessRequest,
    VerifyAuditAccessResponse,
)
from app.modules.system.services import AuditService, BackupService

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


@router.post("/backups/schools/{school_id}", response_model=CreateSchoolBackupResponse)
def create_school_backup(school_id: UUID, db: DBSession, user: CurrentUser):
    return BackupService(db).create_school_backup(school_id, user)


@router.get("/backups/schools/{school_id}", response_model=list[SchoolBackupRead])
def list_school_backups(school_id: UUID, db: DBSession, user: CurrentUser):
    return BackupService(db).list_school_backups(school_id, user)


@router.post(
    "/backups/schools/{school_id}/{backup_id}/restore",
    response_model=RestoreSchoolBackupResponse,
)
def restore_school_backup(
    school_id: UUID,
    backup_id: UUID,
    payload: RestoreSchoolBackupPayload,
    db: DBSession,
    user: CurrentUser,
): 
    if payload.confirm_text.strip().upper() != "RESTAURAR":
        raise HTTPException(status_code=400, detail="Texto de confirmacion invalido")
    return BackupService(db).restore_school_backup(school_id, backup_id, user)


@router.delete(
    "/backups/schools/{school_id}/{backup_id}",
    response_model=DeleteSchoolBackupResponse,
)
def delete_school_backup(school_id: UUID, backup_id: UUID, db: DBSession, user: CurrentUser):
    return BackupService(db).delete_school_backup(school_id, backup_id, user)
