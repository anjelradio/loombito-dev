from __future__ import annotations

from uuid import UUID
from math import ceil

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.modules.schools.models import School, SchoolLevel, SchoolRole, SchoolUser
from app.modules.schools.permissions import ensure_owner
from app.modules.schools.repositories import (
    LevelRepository,
    SchoolLevelRepository,
    SchoolRepository,
    SchoolUserRepository,
)
from app.modules.schools.schemas import (
    PaginatedSchool,
    PaginatedSchoolMember,
    SchoolCreate,
    LevelRead,
    SchoolMemberRead,
    SchoolRead,
    SchoolUsersFilterRole,
    SchoolWithRole,
)
from app.modules.auth.models import User
from app.modules.subscriptions.models import PlanCode, SchoolSubscription
from app.modules.subscriptions.repositories import SubscriptionRepository


class SchoolService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.level = LevelRepository(db)
        self.school_level = SchoolLevelRepository(db)
        self.subscription = SubscriptionRepository(db)

    def list(
        self,
        per_page: int,
        page: int,
    ) -> PaginatedSchool:
        total = self.school.count_active()
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        schools = (
            self.school.list_paginated(
                per_page=per_page,
                page=current_page,
            )
            if total_pages > 0
            else []
        )

        return PaginatedSchool(
            schools=[SchoolRead.model_validate(school) for school in schools],
            page=current_page,
            per_page=per_page,
            total=total,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    def create(self, payload: SchoolCreate, owner_id: UUID) -> School:
        if self.school.get_by_name(payload.name):
            raise HTTPException(
                status_code=409, detail="El nombre de la escuela ya esta en uso"
            )
        if self.school.get_by_phone(payload.phone):
            raise HTTPException(status_code=409, detail="El telefono ya esta en uso")

        levels = self.level.list_by_ids(payload.level_ids)
        if len(levels) != len(payload.level_ids):
            raise HTTPException(status_code=400, detail="Uno o mas niveles no existen")

        try:
            school = School(
                name=payload.name,
                logo_image=payload.logo_image,
                type=payload.type,
                phone=payload.phone,
            )
            self.school.create(school)
            self.db.flush()

            school_user = SchoolUser(
                user_id=owner_id, school_id=school.id, role=SchoolRole.OWNER
            )
            self.school_user.create(school_user)

            free_plan = self.subscription.get_active_plan_by_code(PlanCode.FREE)
            if not free_plan:
                raise HTTPException(status_code=500, detail="No se encontro el plan esencial")

            self.subscription.create_school_subscription(
                SchoolSubscription(
                    school_id=school.id,
                    plan_id=free_plan.id,
                )
            )

            for level_id in payload.level_ids:
                self.school_level.create(
                    SchoolLevel(
                        school_id=school.id,
                        level_id=level_id,
                    )
                )

            self.db.commit()
            self.db.refresh(school)
            self.db.refresh(school_user)
            return school
        except IntegrityError as error:
            self.db.rollback()
            error_message = str(error.orig).lower()
            if "phone" in error_message:
                raise HTTPException(
                    status_code=409, detail="El telefono ya esta en uso"
                )

            raise HTTPException(
                status_code=409, detail="El nombre de la escuela ya esta en uso"
            )
        except Exception:
            self.db.rollback()
            raise

    def list_levels(self) -> list[LevelRead]:
        levels = self.level.list_active()
        return [LevelRead.model_validate(level) for level in levels]

    def list_by_user(self, user_id: UUID) -> list[SchoolWithRole]:
        results = self.school.list_by_user_id(user_id)
        return [
            SchoolWithRole(
                id=school.id,
                name=school.name,
                logo_image=school.logo_image,
                type=school.type,
                phone=school.phone,
                role=SchoolRole(role),
            )
            for school, role in results
        ]

    def list_users_by_school(
        self,
        school_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
        role: SchoolUsersFilterRole | None = None,
        name: str | None = None,
    ) -> PaginatedSchoolMember:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_owner(self.school_user, user_id, school_id)

        target_role = None
        if role == SchoolUsersFilterRole.ADMIN:
            target_role = SchoolRole.ADMIN
        elif role == SchoolUsersFilterRole.TEACHER:
            target_role = SchoolRole.TEACHER

        normalized_name = name.strip() if name else None
        if normalized_name == "":
            normalized_name = None

        total = self.school_user.count_users_by_school_and_role(
            school_id, target_role, normalized_name
        )
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        rows = (
            self.school_user.list_users_by_school_and_role_paginated(
                school_id=school_id,
                per_page=per_page,
                page=current_page,
                role=target_role,
                name=normalized_name,
            )
            if total_pages > 0
            else []
        )

        return PaginatedSchoolMember(
            users=[
                SchoolMemberRead(
                    id=user.id,
                    first_name=user.first_name,
                    last_name=user.last_name,
                    email=user.email,
                    role=member_role,
                    created_date=created_date,
                )
                for user, member_role, created_date in rows
            ],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    def delete_user_from_school(
        self, school_id: UUID, user_id: UUID, target_user_id: UUID
    ) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_owner(self.school_user, user_id, school_id)

        target_memberships = self.school_user.list_non_owner_by_user_and_school(
            target_user_id, school_id
        )
        if not target_memberships:
            raise HTTPException(
                status_code=404, detail="Usuario no encontrado en la escuela"
            )

        for membership in target_memberships:
            self.school_user.delete(membership)

        self.db.commit()

    def toggle_user_role_in_school(
        self, school_id: UUID, user_id: UUID, target_user_id: UUID
    ) -> SchoolMemberRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_owner(self.school_user, user_id, school_id)

        target_memberships = self.school_user.list_manageable_roles_by_user_and_school(
            target_user_id, school_id
        )
        if not target_memberships:
            raise HTTPException(
                status_code=404, detail="Usuario no encontrado en la escuela"
            )

        if len(target_memberships) > 1:
            raise HTTPException(
                status_code=409,
                detail="El usuario tiene multiples roles activos y no se puede alternar automaticamente",
            )

        membership = target_memberships[0]
        membership.role = (
            SchoolRole.TEACHER
            if membership.role == SchoolRole.ADMIN
            else SchoolRole.ADMIN
        )
        self.school_user.update(membership)
        self.db.commit()
        self.db.refresh(membership)

        target_user = self.db.get(User, target_user_id)
        if not target_user or not target_user.state:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")

        return SchoolMemberRead(
            id=target_user.id,
            first_name=target_user.first_name,
            last_name=target_user.last_name,
            email=target_user.email,
            role=membership.role,
            created_date=membership.created_date,
        )
