from uuid import UUID

from fastapi import APIRouter, Query, Response, status

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.communications.schemas import (
    NotificationRead,
    StudentCommunicationCreate,
    StudentCommunicationRead,
    StudentCommunicationUpdate,
    TeacherCommunicationCourseRead,
    TeacherCommunicationCourseStudentRead,
)
from app.modules.communications.services import CommunicationService

router = APIRouter(prefix="/communications", tags=["Comunicaciones"])


@router.get(
    "/teacher/schools/{school_id}/courses",
    response_model=list[TeacherCommunicationCourseRead],
)
def list_teacher_courses_for_communications(school_id: UUID, db: DBSession, actor: CurrentActor):
    return CommunicationService(db).list_teacher_courses(school_id, actor)


@router.get(
    "/teacher/schools/{school_id}/courses/{course_id}/students",
    response_model=list[TeacherCommunicationCourseStudentRead],
)
def list_teacher_students_by_course_for_communications(
    school_id: UUID,
    course_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return CommunicationService(db).list_teacher_students_by_course(school_id, course_id, actor)


@router.post(
    "/schools/{school_id}/students/{student_id}/communications",
    response_model=StudentCommunicationRead,
)
def create_student_communication(
    school_id: UUID,
    student_id: UUID,
    payload: StudentCommunicationCreate,
    db: DBSession,
    actor: CurrentActor,
):
    return CommunicationService(db).create_student_communication(school_id, student_id, payload, actor)


@router.get(
    "/schools/{school_id}/students/{student_id}/communications",
    response_model=list[StudentCommunicationRead],
)
def list_student_communications(
    school_id: UUID,
    student_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return CommunicationService(db).list_student_communications(school_id, student_id, actor)


@router.put(
    "/schools/{school_id}/communications/{communication_id}",
    response_model=StudentCommunicationRead,
)
def update_student_communication(
    school_id: UUID,
    communication_id: UUID,
    payload: StudentCommunicationUpdate,
    db: DBSession,
    actor: CurrentActor,
):
    return CommunicationService(db).update_student_communication(
        school_id,
        communication_id,
        payload,
        actor,
    )


@router.delete(
    "/schools/{school_id}/communications/{communication_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_student_communication(
    school_id: UUID,
    communication_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    CommunicationService(db).delete_student_communication(school_id, communication_id, actor)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/notifications", response_model=list[NotificationRead])
def list_my_notifications(
    db: DBSession,
    actor: CurrentActor,
    only_unread: bool = Query(True),
):
    return CommunicationService(db).list_my_notifications(actor, only_unread)


@router.patch("/notifications/{notification_id}/read", response_model=NotificationRead)
def mark_notification_as_read(notification_id: UUID, db: DBSession, actor: CurrentActor):
    return CommunicationService(db).mark_my_notification_as_read(notification_id, actor)
