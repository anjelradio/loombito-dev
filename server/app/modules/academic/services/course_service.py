from math import ceil
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, select

from app.dependencies.auth import CurrentActorContext
from app.modules.academic.models import Course
from app.modules.academic.permissions import ensure_admin_or_owner
from app.modules.academic.repositories import (
    CourseRepository,
    CourseSubjectRepository,
    SubjectRepository,
)
from app.modules.academic.schemas import (
    CourseCreate,
    CourseFormOptionsRead,
    CourseRead,
    CourseUpdate,
    PaginatedCourse,
    SchoolLevelOptionRead,
    SubjectOptionRead,
)
from app.modules.schools.models import Level, SchoolLevel
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class CourseService:
    def __init__(self, db: Session):
        self.db = db
        self.course = CourseRepository(db)
        self.course_subject = CourseSubjectRepository(db)
        self.subject = SubjectRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    def _get_school_level_option(self, school_id: UUID, school_level_id: UUID):
        query = (
            select(SchoolLevel, Level.name)
            .join(Level, Level.id == SchoolLevel.level_id)
            .where(
                SchoolLevel.id == school_level_id,
                SchoolLevel.school_id == school_id,
                SchoolLevel.state == True,
                Level.state == True,
            )
        )
        return self.db.exec(query).first()

    def _validate_subject_ids(self, school_id: UUID, subject_ids: list[UUID]) -> None:
        subjects = self.subject.list_active_by_ids_in_school(school_id, subject_ids)
        if len(subjects) != len(subject_ids):
            raise HTTPException(status_code=400, detail="Una o mas materias no existen")

    def _replace_course_subjects(
        self, course_id: UUID, subject_ids: list[UUID]
    ) -> None:
        self.course_subject.replace_for_course(course_id, subject_ids)

    def _to_course_read(self, course: Course, level_name: str) -> CourseRead:
        subject_ids = self.course_subject.list_active_subject_ids_by_course(course.id)
        subject_names = self.course_subject.list_active_subject_names_by_course(course.id)
        return CourseRead(
            id=course.id,
            name=course.name,
            school_id=course.school_id,
            school_level_id=course.school_level_id,
            level_name=level_name,
            subject_ids=subject_ids,
            subject_names=subject_names,
        )

    def get_by_id(self, school_id: UUID, course_id: UUID, user_id: UUID) -> CourseRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, user_id, school_id)

        course = self.course.get_active_by_id_in_school(school_id, course_id)
        if not course:
            raise HTTPException(status_code=404, detail="Curso no encontrado")

        school_level_row = self._get_school_level_option(school_id, course.school_level_id)
        if not school_level_row:
            raise HTTPException(status_code=404, detail="Nivel del curso no encontrado")

        _, level_name = school_level_row
        return self._to_course_read(course, level_name)

    def get_form_options(self, school_id: UUID, user_id: UUID) -> CourseFormOptionsRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, user_id, school_id)

        school_levels_query = (
            select(SchoolLevel, Level.name)
            .join(Level, Level.id == SchoolLevel.level_id)
            .where(
                SchoolLevel.school_id == school_id,
                SchoolLevel.state == True,
                Level.state == True,
            )
            .order_by(Level.name.asc())
        )
        school_levels = self.db.exec(school_levels_query).all()

        subjects = self.subject.list_active_by_school(school_id)

        return CourseFormOptionsRead(
            school_levels=[
                SchoolLevelOptionRead(id=school_level.id, name=level_name)
                for school_level, level_name in school_levels
            ],
            subjects=[
                SubjectOptionRead(id=subject.id, name=subject.name)
                for subject in subjects
            ],
        )

    def create(
        self, school_id: UUID, payload: CourseCreate, actor: CurrentActorContext
    ) -> CourseRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        school_level_row = self._get_school_level_option(
            school_id, payload.school_level_id
        )
        if not school_level_row:
            raise HTTPException(
                status_code=400, detail="El nivel seleccionado no existe"
            )

        existing = self.course.get_by_name_and_level_in_school(
            school_id, payload.school_level_id, payload.name
        )
        if existing:
            raise HTTPException(
                status_code=409,
                detail="El nombre del curso ya existe para este nivel",
            )

        self._validate_subject_ids(school_id, payload.subject_ids)

        try:
            course = Course(
                name=payload.name,
                school_id=school_id,
                school_level_id=payload.school_level_id,
            )
            self.course.create(course)
            self.db.flush()

            self._replace_course_subjects(course.id, payload.subject_ids)

            self.db.commit()
            self.db.refresh(course)

            _, level_name = school_level_row
            self.audit_logger.safe_log_school_success(
                action=AuditAction.CREATE,
                description="Creacion de curso exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return self._to_course_read(course, level_name)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=409,
                detail="El curso no pudo crearse por conflicto de datos",
            )
        except Exception:
            self.db.rollback()
            raise

    def update(
        self,
        school_id: UUID,
        course_id: UUID,
        payload: CourseUpdate,
        actor: CurrentActorContext,
    ) -> CourseRead:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        course = self.course.get_active_by_id_in_school(school_id, course_id)
        if not course:
            raise HTTPException(status_code=404, detail="Curso no encontrado")

        school_level_row = self._get_school_level_option(
            school_id, payload.school_level_id
        )
        if not school_level_row:
            raise HTTPException(
                status_code=400, detail="El nivel seleccionado no existe"
            )

        existing = self.course.get_by_name_and_level_in_school(
            school_id, payload.school_level_id, payload.name
        )
        if existing and existing.id != course_id:
            raise HTTPException(
                status_code=409,
                detail="El nombre del curso ya existe para este nivel",
            )

        self._validate_subject_ids(school_id, payload.subject_ids)

        try:
            course.name = payload.name
            course.school_level_id = payload.school_level_id
            self.course.update(course)
            self._replace_course_subjects(course.id, payload.subject_ids)

            self.db.commit()
            self.db.refresh(course)

            _, level_name = school_level_row
            self.audit_logger.safe_log_school_success(
                action=AuditAction.UPDATE,
                description="Actualizacion de curso exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return self._to_course_read(course, level_name)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=409,
                detail="El curso no pudo actualizarse por conflicto de datos",
            )
        except Exception:
            self.db.rollback()
            raise

    def delete(self, school_id: UUID, course_id: UUID, actor: CurrentActorContext) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        course = self.course.get_active_by_id_in_school(school_id, course_id)
        if not course:
            raise HTTPException(status_code=404, detail="Curso no encontrado")

        self.course.delete(course)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de curso exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    def list_by_school(
        self,
        school_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
        search: str | None = None,
    ) -> PaginatedCourse:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, user_id, school_id)

        total = self.course.count_active_by_school(school_id, search)
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        rows = (
            self.course.list_paginated_by_school(
                school_id,
                search,
                per_page=per_page,
                page=current_page,
            )
            if total_pages > 0
            else []
        )

        return PaginatedCourse(
            courses=[
                self._to_course_read(course, level_name)
                for course, level_name in rows
            ],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )
