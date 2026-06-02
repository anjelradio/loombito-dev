from datetime import datetime
from uuid import UUID

from sqlmodel import Session, select

from app.modules.communications.models import PushToken


class PushTokenRepository:
    def __init__(self, db: Session):
        self.db = db

    def upsert(self, user_id: UUID, token: str, platform: str) -> PushToken:
        row = self.db.exec(select(PushToken).where(PushToken.token == token)).first()
        if row:
            row.user_id = user_id
            row.platform = platform
            row.state = True
            row.deleted_date = None
            row.modified_date = datetime.utcnow()
            self.db.add(row)
            return row

        row = PushToken(user_id=user_id, token=token, platform=platform)
        self.db.add(row)
        return row

    def list_active_by_user_ids(self, user_ids: list[UUID]) -> list[PushToken]:
        if not user_ids:
            return []

        query = select(PushToken).where(
            PushToken.user_id.in_(user_ids),
            PushToken.state == True,
        )
        return self.db.exec(query).all()
