from math import ceil
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.auth.models import User
from app.modules.academic.models import Course
from app.modules.academic.permissions import ensure_admin_or_owner
from app.modules.academic.repositories import AssignmentRepository
from app.modules.academic.schemas import (
    AssignmentCourseGroupRead,
    AssignmentCourseOptionRead,
    AssignmentCreate,
    AssignmentSubjectOptionRead,
    AssignmentSubjectRead,
    AssignmentTeacherRead,
    AssignmentUpdate,
    PaginatedAssignmentTeacher,
    TeacherAssignmentsRead,
)
from app.modules.schools.models import SchoolRole, SchoolUser
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class AssignmentService:
    def __init__(self, db: Session):
        self.db = db
        self.assignment = AssignmentRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    def _ensure_school_and_permissions(self, school_id: UUID, user_id: UUID) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")
        ensure_admin_or_owner(self.school_user, user_id, school_id)

    def _ensure_teacher_in_school(self, school_id: UUID, teacher_id: UUID) -> None:
        teacher_membership = self.db.get(SchoolUser, teacher_id)
        if (
            not teacher_membership
            or not teacher_membership.state
            or teacher_membership.school_id != school_id
            or teacher_membership.role != SchoolRole.TEACHER
        ):
            raise HTTPException(status_code=404, detail="Docente no encontrado en esta escuela")

    def _ensure_course_in_school(self, school_id: UUID, course_id: UUID) -> None:
        course = self.db.get(Course, course_id)
        if not course or not course.state or course.school_id != school_id:
            raise HTTPException(status_code=404, detail="Curso no encontrado en esta escuela")

    def _get_valid_course_subject_ids(
        self, school_id: UUID, course_id: UUID, subject_ids: list[UUID]
    ) -> list[UUID]:
        self._ensure_course_in_school(school_id, course_id)
        course_subject_ids = self.assignment.get_course_subject_ids_by_course_and_subjects(
            course_id, subject_ids
        )
        if len(course_subject_ids) != len(subject_ids):
            raise HTTPException(
                status_code=400,
                detail="Una o mas materias no pertenecen al curso seleccionado",
            )
        return course_subject_ids

    def list_teachers(
        self,
        school_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
        search: str | None = None,
    ) -> PaginatedAssignmentTeacher:
        self._ensure_school_and_permissions(school_id, user_id)

        total = self.school_user.count_users_by_school_and_role(
            school_id,
            role=SchoolRole.TEACHER,
            name=search,
        )
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        rows = (
            self.school_user.list_users_by_school_and_role_paginated(
                school_id,
                per_page,
                current_page,
                role=SchoolRole.TEACHER,
                name=search,
            )
            if total_pages > 0
            else []
        )

        teachers = []
        for user, _, _ in rows:
            membership = self.school_user.get_by_user_school_and_role(
                user.id,
                school_id,
                SchoolRole.TEACHER,
            )
            if not membership:
                continue
            course_names = self.assignment.list_teacher_course_names(school_id, membership.id)
            teachers.append(
                AssignmentTeacherRead(
                    teacher_id=membership.id,
                    first_name=user.first_name,
                    last_name=user.last_name,
                    course_names=course_names,
                )
            )

        return PaginatedAssignmentTeacher(
            teachers=teachers,
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    def list_course_options(self, school_id: UUID, user_id: UUID) -> list[AssignmentCourseOptionRead]:
        self._ensure_school_and_permissions(school_id, user_id)
        rows = self.assignment.list_courses_with_subjects(school_id)
        return [AssignmentCourseOptionRead(course_id=course_id, course_name=course_name) for course_id, course_name in rows]

    def list_subject_options_by_course(
        self,
        school_id: UUID,
        course_id: UUID,
        user_id: UUID,
    ) -> list[AssignmentSubjectOptionRead]:
        self._ensure_school_and_permissions(school_id, user_id)
        self._ensure_course_in_school(school_id, course_id)
        rows = self.assignment.list_subjects_by_course(school_id, course_id)
        return [
            AssignmentSubjectOptionRead(subject_id=subject_id, subject_name=subject_name)
            for subject_id, subject_name in rows
        ]

    def list_teacher_assignments(
        self,
        school_id: UUID,
        teacher_id: UUID,
        user_id: UUID,
    ) -> TeacherAssignmentsRead:
        self._ensure_school_and_permissions(school_id, user_id)
        self._ensure_teacher_in_school(school_id, teacher_id)

        teacher_membership = self.db.get(SchoolUser, teacher_id)
        if not teacher_membership:
            raise HTTPException(status_code=404, detail="Docente no encontrado en esta escuela")

        teacher_user = self.db.get(User, teacher_membership.user_id)
        if not teacher_user or not teacher_user.state:
            raise HTTPException(status_code=404, detail="Docente no encontrado en esta escuela")

        rows = self.assignment.list_teacher_assignments_rows(school_id, teacher_id)
        grouped: dict[UUID, AssignmentCourseGroupRead] = {}

        for course_id, course_name, subject_id, subject_name in rows:
            if course_id not in grouped:
                grouped[course_id] = AssignmentCourseGroupRead(
                    course_id=course_id,
                    course_name=course_name,
                    subjects=[],
                )
            grouped[course_id].subjects.append(
                AssignmentSubjectRead(subject_id=subject_id, subject_name=subject_name)
            )

        return TeacherAssignmentsRead(
            teacher_id=teacher_id,
            first_name=teacher_user.first_name,
            last_name=teacher_user.last_name,
            assignments=list(grouped.values()),
        )

    def create_for_teacher(
        self,
        school_id: UUID,
        teacher_id: UUID,
        payload: AssignmentCreate,
        actor: CurrentActorContext,
    ) -> TeacherAssignmentsRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)
        self._ensure_teacher_in_school(school_id, teacher_id)

        current = self.assignment.list_active_by_teacher_and_course(
            school_id,
            teacher_id,
            payload.course_id,
        )
        if current:
            raise HTTPException(
                status_code=409,
                detail="El docente ya tiene una asignacion en este curso. Usa editar para reemplazar materias.",
            )

        course_subject_ids = self._get_valid_course_subject_ids(
            school_id,
            payload.course_id,
            payload.subject_ids,
        )

        try:
            self.assignment.create_many(school_id, teacher_id, course_subject_ids)
            self.db.commit()
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo crear la asignacion")
        except Exception:
            self.db.rollback()
            raise

        self.audit_logger.safe_log_school_success(
            action=AuditAction.CREATE,
            description="Creacion de asignacion docente exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
        return self.list_teacher_assignments(school_id, teacher_id, actor.user.id)

    def replace_teacher_course_subjects(
        self,
        school_id: UUID,
        teacher_id: UUID,
        course_id: UUID,
        payload: AssignmentUpdate,
        actor: CurrentActorContext,
    ) -> TeacherAssignmentsRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)
        self._ensure_teacher_in_school(school_id, teacher_id)

        current = self.assignment.list_active_by_teacher_and_course(school_id, teacher_id, course_id)
        if not current:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada para este curso")

        course_subject_ids = self._get_valid_course_subject_ids(
            school_id,
            course_id,
            payload.subject_ids,
        )

        try:
            self.assignment.soft_delete_many(current)
            self.assignment.create_many(school_id, teacher_id, course_subject_ids)
            self.db.commit()
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo actualizar la asignacion")
        except Exception:
            self.db.rollback()
            raise

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Actualizacion de asignacion docente exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
        return self.list_teacher_assignments(school_id, teacher_id, actor.user.id)

    def delete_teacher_course_assignments(
        self,
        school_id: UUID,
        teacher_id: UUID,
        course_id: UUID,
        actor: CurrentActorContext,
    ) -> None:
        self._ensure_school_and_permissions(school_id, actor.user.id)
        self._ensure_teacher_in_school(school_id, teacher_id)

        current = self.assignment.list_active_by_teacher_and_course(school_id, teacher_id, course_id)
        if not current:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada para este curso")

        self.assignment.soft_delete_many(current)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de asignacion docente exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )
