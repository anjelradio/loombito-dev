from uuid import UUID

from fastapi import HTTPException

from app.modules.schools.models import SchoolRole
from app.modules.schools.repositories import SchoolUserRepository


def ensure_admin_or_owner_in_school(
    school_user_repo: SchoolUserRepository,
    user_id: UUID,
    school_id: UUID,
) -> None:
    membership = school_user_repo.get_by_user_and_school(user_id, school_id)
    if not membership:
        raise HTTPException(status_code=403, detail="No perteneces a esta escuela")
    if membership.role not in [SchoolRole.OWNER, SchoolRole.ADMIN]:
        raise HTTPException(status_code=403, detail="Solo admin u owner pueden gestionar reportes")


def ensure_admin_owner_or_teacher_in_school(
    school_user_repo: SchoolUserRepository,
    user_id: UUID,
    school_id: UUID,
) -> None:
    membership = school_user_repo.get_by_user_and_school(user_id, school_id)
    if not membership:
        raise HTTPException(status_code=403, detail="No perteneces a esta escuela")
    if membership.role not in [SchoolRole.OWNER, SchoolRole.ADMIN, SchoolRole.TEACHER]:
        raise HTTPException(status_code=403, detail="No tienes permisos para generar este reporte")
