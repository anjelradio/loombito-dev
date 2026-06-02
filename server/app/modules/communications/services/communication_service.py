from uuid import UUID
import logging

from fastapi import HTTPException
from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Course, CourseSubject
from app.dependencies.auth import CurrentActorContext
from app.modules.communications.models import StudentCommunication
from app.modules.communications.permissions import ensure_teacher_in_school
from app.modules.communications.repositories import (
    NotificationRepository,
    StudentCommunicationRepository,
)
from app.modules.communications.schemas import (
    NotificationRead,
    StudentCommunicationCreate,
    StudentCommunicationRead,
    StudentCommunicationUpdate,
    TeacherCommunicationCourseRead,
    TeacherCommunicationCourseStudentRead,
)
from app.modules.communications.services.notification_service import NotificationService
from app.modules.communications.services.push_notification_service import PushNotificationService
from app.modules.schools.models import SchoolRole
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.students.repositories import CourseStudentRepository, StudentRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


logger = logging.getLogger(__name__)


class CommunicationService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.student = StudentRepository(db)
        self.course_student = CourseStudentRepository(db)
        self.communication = StudentCommunicationRepository(db)
        self.notification = NotificationRepository(db)
        self.notification_service = NotificationService(db)
        self.push_notification = PushNotificationService(db)
        self.audit_logger = AuditLogger(db)

    def _ensure_school_student_and_teacher(self, school_id: UUID, student_id: UUID, actor: CurrentActorContext):
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_teacher_in_school(self.school_user, actor.user.id, school_id)

        student = self.student.get_active_by_id_in_school(school_id, student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")

        return student

    def list_teacher_courses(
        self,
        school_id: UUID,
        actor: CurrentActorContext,
    ) -> list[TeacherCommunicationCourseRead]:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        membership = self.school_user.get_by_user_school_and_role(
            actor.user.id,
            school_id,
            role=SchoolRole.TEACHER,
        )
        if not membership:
            raise HTTPException(status_code=403, detail="No autorizado")

        query = (
            select(Course.id, Course.name)
            .join(CourseSubject, CourseSubject.course_id == Course.id)
            .join(Assignment, Assignment.course_subject_id == CourseSubject.id)
            .where(
                Assignment.school_id == school_id,
                Assignment.teacher_id == membership.id,
                Assignment.state == True,
                Course.state == True,
                Course.school_id == school_id,
                CourseSubject.state == True,
            )
            .distinct()
            .order_by(Course.name.asc())
        )
        rows = self.db.exec(query).all()
        return [TeacherCommunicationCourseRead(id=course_id, name=course_name) for course_id, course_name in rows]

    def list_teacher_students_by_course(
        self,
        school_id: UUID,
        course_id: UUID,
        actor: CurrentActorContext,
    ) -> list[TeacherCommunicationCourseStudentRead]:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_teacher_in_school(self.school_user, actor.user.id, school_id)
        membership = self.school_user.get_by_user_school_and_role(
            actor.user.id,
            school_id,
            role=SchoolRole.TEACHER,
        )
        if not membership:
            raise HTTPException(status_code=403, detail="No autorizado")

        course = self.db.get(Course, course_id)
        if not course or not course.state or course.school_id != school_id:
            raise HTTPException(status_code=404, detail="Curso no encontrado en esta escuela")

        assignment_query = (
            select(Assignment.id)
            .join(CourseSubject, CourseSubject.id == Assignment.course_subject_id)
            .where(
                Assignment.school_id == school_id,
                Assignment.teacher_id == membership.id,
                Assignment.state == True,
                CourseSubject.course_id == course_id,
                CourseSubject.state == True,
            )
        )
        has_assignment = self.db.exec(assignment_query).first()
        if not has_assignment:
            raise HTTPException(status_code=403, detail="No puedes gestionar comunicados de este curso")

        students = self.course_student.list_active_students_by_course_without_pagination(school_id, course_id)
        return [
            TeacherCommunicationCourseStudentRead(
                id=student.id,
                first_name=student.first_name,
                last_name=student.last_name,
            )
            for student in students
        ]

    def create_student_communication(
        self,
        school_id: UUID,
        student_id: UUID,
        payload: StudentCommunicationCreate,
        actor: CurrentActorContext,
    ) -> StudentCommunicationRead:
        self._ensure_school_student_and_teacher(school_id, student_id, actor)

        row = StudentCommunication(
            school_id=school_id,
            student_id=student_id,
            author_user_id=actor.user.id,
            title=payload.title,
            body=payload.body,
        )
        self.communication.create(row)
        self.notification_service.create_for_student_parents(
            school_id=school_id,
            student_id=student_id,
            title=payload.title,
            body=payload.body,
        )
        self.db.commit()
        self.db.refresh(row)

        self.audit_logger.safe_log_school_success(
            action=AuditAction.CREATE,
            description="Creacion de comunicacion de estudiante exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        try:
            self.push_notification.send_to_student_parents(
                school_id=school_id,
                student_id=student_id,
                title=row.title,
                body=row.body,
                event="created",
                communication_id=row.id,
            )
        except Exception:
            logger.exception("No se pudo enviar push de comunicacion creada")

        return StudentCommunicationRead.model_validate(row)

    def update_student_communication(
        self,
        school_id: UUID,
        communication_id: UUID,
        payload: StudentCommunicationUpdate,
        actor: CurrentActorContext,
    ) -> StudentCommunicationRead:
        row = self.communication.get_active_by_id(communication_id)
        if not row or row.school_id != school_id:
            raise HTTPException(status_code=404, detail="Comunicacion no encontrada")

        self._ensure_school_student_and_teacher(school_id, row.student_id, actor)
        if row.author_user_id != actor.user.id:
            raise HTTPException(status_code=403, detail="Solo puedes editar tus propias comunicaciones")

        previous_title = row.title
        previous_body = row.body

        row.title = payload.title
        row.body = payload.body
        self.communication.update(row)

        self.notification.delete_matching_by_student_and_content(
            school_id=school_id,
            student_id=row.student_id,
            title=previous_title,
            body=previous_body,
        )
        self.notification_service.create_for_student_parents(
            school_id=school_id,
            student_id=row.student_id,
            title=row.title,
            body=row.body,
        )

        self.db.commit()
        self.db.refresh(row)

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Actualizacion de comunicacion de estudiante exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        try:
            self.push_notification.send_to_student_parents(
                school_id=school_id,
                student_id=row.student_id,
                title=row.title,
                body=row.body,
                event="updated",
                communication_id=row.id,
            )
        except Exception:
            logger.exception("No se pudo enviar push de comunicacion actualizada")

        return StudentCommunicationRead.model_validate(row)

    def delete_student_communication(
        self,
        school_id: UUID,
        communication_id: UUID,
        actor: CurrentActorContext,
    ) -> None:
        row = self.communication.get_active_by_id(communication_id)
        if not row or row.school_id != school_id:
            raise HTTPException(status_code=404, detail="Comunicacion no encontrada")

        self._ensure_school_student_and_teacher(school_id, row.student_id, actor)
        if row.author_user_id != actor.user.id:
            raise HTTPException(status_code=403, detail="Solo puedes eliminar tus propias comunicaciones")

        self.communication.delete(row)
        self.notification.delete_matching_by_student_and_content(
            school_id=school_id,
            student_id=row.student_id,
            title=row.title,
            body=row.body,
        )
        self.db.commit()

        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de comunicacion de estudiante exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    def list_student_communications(
        self,
        school_id: UUID,
        student_id: UUID,
        actor: CurrentActorContext,
    ) -> list[StudentCommunicationRead]:
        self._ensure_school_student_and_teacher(school_id, student_id, actor)
        rows = self.communication.list_active_by_student(school_id, student_id)
        return [StudentCommunicationRead.model_validate(row) for row in rows]

    def list_my_notifications(
        self,
        actor: CurrentActorContext,
        only_unread: bool,
    ) -> list[NotificationRead]:
        rows = self.notification.list_by_recipient(actor.user.id, only_unread=only_unread)
        return [NotificationRead.model_validate(row) for row in rows]

    def mark_my_notification_as_read(
        self,
        notification_id: UUID,
        actor: CurrentActorContext,
    ) -> NotificationRead:
        row = self.notification.get_active_by_id_for_recipient(notification_id, actor.user.id)
        if not row:
            raise HTTPException(status_code=404, detail="Notificacion no encontrada")

        if not row.is_read:
            self.notification.mark_as_read(row)
            self.db.commit()
            self.db.refresh(row)

        return NotificationRead.model_validate(row)
