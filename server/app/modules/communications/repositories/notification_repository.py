from datetime import datetime
from uuid import UUID

from sqlmodel import Session, select

from app.modules.communications.models import Notification


class NotificationRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_many(self, notifications: list[Notification]) -> list[Notification]:
        for notification in notifications:
            self.db.add(notification)
        return notifications

    def list_by_recipient(self, recipient_user_id: UUID, only_unread: bool = True) -> list[Notification]:
        query = select(Notification).where(
            Notification.recipient_user_id == recipient_user_id,
            Notification.state == True,
        )
        if only_unread:
            query = query.where(Notification.is_read == False)

        query = query.order_by(Notification.created_date.desc())
        return self.db.exec(query).all()

    def get_active_by_id_for_recipient(
        self, notification_id: UUID, recipient_user_id: UUID
    ) -> Notification | None:
        query = select(Notification).where(
            Notification.id == notification_id,
            Notification.recipient_user_id == recipient_user_id,
            Notification.state == True,
        )
        return self.db.exec(query).first()

    def mark_as_read(self, notification: Notification) -> Notification:
        notification.is_read = True
        notification.read_at = datetime.utcnow()
        self.db.add(notification)
        return notification

    def delete_matching_by_student_and_content(
        self,
        school_id: UUID,
        student_id: UUID,
        title: str,
        body: str,
    ) -> int:
        query = select(Notification).where(
            Notification.school_id == school_id,
            Notification.student_id == student_id,
            Notification.title == title,
            Notification.body == body,
            Notification.state == True,
        )
        rows = self.db.exec(query).all()
        for row in rows:
            row.state = False
            self.db.add(row)
        return len(rows)
