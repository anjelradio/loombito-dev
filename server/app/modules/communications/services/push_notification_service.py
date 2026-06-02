from __future__ import annotations

import json
import logging
from pathlib import Path
from uuid import UUID

from firebase_admin import credentials, initialize_app, messaging
from firebase_admin import _apps as firebase_apps
from sqlmodel import Session

from app.core.config import settings
from app.modules.communications.repositories import PushTokenRepository
from app.modules.students.repositories import StudentParentRepository

logger = logging.getLogger(__name__)


class PushNotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.push_tokens = PushTokenRepository(db)
        self.student_parent = StudentParentRepository(db)
        self._ensure_app()

    def _ensure_app(self) -> None:
        if firebase_apps:
            return

        cred = None
        if settings.FIREBASE_CREDENTIALS_PATH:
            cred = credentials.Certificate(str(Path(settings.FIREBASE_CREDENTIALS_PATH)))
        elif settings.FIREBASE_CREDENTIALS_JSON:
            cred = credentials.Certificate(json.loads(settings.FIREBASE_CREDENTIALS_JSON))

        if cred is None:
            logger.warning("Firebase credentials not configured; push notifications disabled")
            return

        options = {}
        if settings.FIREBASE_PROJECT_ID:
            options["projectId"] = settings.FIREBASE_PROJECT_ID

        initialize_app(cred, options=options or None)

    def send_to_student_parents(
        self,
        school_id: UUID,
        student_id: UUID,
        title: str,
        body: str,
        event: str,
        communication_id: UUID,
    ) -> int:
        if not firebase_apps:
            return 0

        recipient_ids = self.student_parent.list_active_parent_user_ids_by_student(student_id)
        if not recipient_ids:
            return 0

        tokens = self.push_tokens.list_active_by_user_ids(recipient_ids)
        if not tokens:
            return 0

        base_data = {
            "type": "student_communication",
            "event": event,
            "communication_id": str(communication_id),
            "school_id": str(school_id),
            "student_id": str(student_id),
        }
        sent = 0
        chunk_size = 500
        token_values = [row.token for row in tokens]

        for i in range(0, len(token_values), chunk_size):
            chunk = token_values[i : i + chunk_size]
            if not chunk:
                continue

            message = messaging.MulticastMessage(
                tokens=chunk,
                notification=messaging.Notification(title=title, body=body),
                data=base_data,
            )
            result = messaging.send_each_for_multicast(message)
            sent += result.success_count

        return sent
