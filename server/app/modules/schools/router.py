from uuid import UUID

from fastapi import APIRouter, Query, Response, status

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.schools.schemas import (
    LevelRead,
    PaginatedSchool,
    PaginatedSchoolMember,
    SchoolCreate,
    SchoolInviteCreate,
    SchoolInviteRead,
    SchoolJoinByCode,
    SchoolMemberRead,
    SchoolRead,
    SchoolUsersFilterRole,
    SchoolWithRole,
)
from app.modules.schools.services import SchoolInviteService, SchoolService

router = APIRouter(prefix="/schools", tags=["Escuela"])


@router.get("/", response_model=PaginatedSchool)
def list_schools(
    db: DBSession,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
):
    return SchoolService(db).list(per_page, page)


@router.post("/", response_model=SchoolRead)
def create_school(db: DBSession, payload: SchoolCreate, actor: CurrentActor):
    return SchoolService(db).create(payload, actor)


@router.get("/levels", response_model=list[LevelRead])
def list_levels(db: DBSession):
    return SchoolService(db).list_levels()


@router.get("/by_user", response_model=list[SchoolWithRole])
def list_school_by_user(db: DBSession, actor: CurrentActor):
    return SchoolService(db).list_by_user(actor.user.id)


@router.get("/{school_id}/users", response_model=PaginatedSchoolMember)
def list_users_by_school(
    db: DBSession,
    school_id: UUID,
    actor: CurrentActor,
    per_page: int = Query(8, ge=1, le=50, description="Numero de resultados"),
    page: int = Query(1, ge=1, description="Numero de pagina"),
    role: SchoolUsersFilterRole | None = None,
    name: str | None = Query(None, min_length=1, description="Filtro por nombre"),
):
    return SchoolService(db).list_users_by_school(
        school_id, actor, per_page, page, role, name
    )


@router.delete(
    "/{school_id}/users/{target_user_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_user_from_school(
    school_id: UUID, target_user_id: UUID, db: DBSession, actor: CurrentActor
):
    SchoolService(db).delete_user_from_school(school_id, actor, target_user_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.patch(
    "/{school_id}/users/{target_user_id}/role", response_model=SchoolMemberRead
)
def toggle_user_role_in_school(
    school_id: UUID, target_user_id: UUID, db: DBSession, actor: CurrentActor
):
    return SchoolService(db).toggle_user_role_in_school(
        school_id, actor, target_user_id
    )


@router.post("/{school_id}/invite", response_model=SchoolInviteRead)
def create_school_invite(
    school_id: UUID, db: DBSession, payload: SchoolInviteCreate, actor: CurrentActor
):
    return SchoolInviteService(db).create(school_id, payload, actor)


@router.get("/{school_id}/invite", response_model=list[SchoolInviteRead])
def list_school_invites(school_id: UUID, db: DBSession, actor: CurrentActor):
    return SchoolInviteService(db).list_by_school(school_id, actor)


@router.delete(
    "/{school_id}/invite/{invite_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_school_invite(
    school_id: UUID, invite_id: UUID, db: DBSession, actor: CurrentActor
):
    SchoolInviteService(db).delete(school_id, invite_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/join", response_model=SchoolWithRole)
def join_school_with_code(db: DBSession, payload: SchoolJoinByCode, actor: CurrentActor):
    return SchoolInviteService(db).join_by_code(payload, actor)
