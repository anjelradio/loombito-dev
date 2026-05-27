from uuid import UUID

from sqlmodel import Session

from app.modules.communications.models import Notification
from app.modules.communications.repositories import NotificationRepository
from app.modules.students.repositories import StudentParentRepository


class NotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.notification = NotificationRepository(db)
        self.student_parent = StudentParentRepository(db)

    def create_for_student_parents(
        self,
        school_id: UUID,
        student_id: UUID,
        title: str,
        body: str,
    ) -> int:
        recipient_ids = self.student_parent.list_active_parent_user_ids_by_student(student_id)
        if not recipient_ids:
            return 0

        rows = [
            Notification(
                recipient_user_id=recipient_id,
                school_id=school_id,
                student_id=student_id,
                title=title,
                body=body,
            )
            for recipient_id in recipient_ids
        ]
        self.notification.create_many(rows)
        return len(rows)
