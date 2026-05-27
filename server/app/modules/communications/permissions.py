from uuid import UUID

from fastapi import HTTPException

from app.modules.schools.models import SchoolRole
from app.modules.schools.repositories import SchoolUserRepository


def ensure_teacher_in_school(
    school_user_repo: SchoolUserRepository,
    user_id: UUID,
    school_id: UUID,
) -> None:
    membership = school_user_repo.get_by_user_school_and_role(
        user_id,
        school_id,
        SchoolRole.TEACHER,
    )
    if not membership:
        raise HTTPException(
            status_code=403,
            detail="Solo un docente de la escuela puede gestionar este recurso",
        )
