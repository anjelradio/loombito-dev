from fastapi import HTTPException
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.communications.repositories import PushTokenRepository
from app.modules.communications.schemas import PushTokenRead, PushTokenRegister


class PushTokenService:
    def __init__(self, db: Session):
        self.db = db
        self.push_tokens = PushTokenRepository(db)

    def register_token(
        self,
        actor: CurrentActorContext,
        payload: PushTokenRegister,
    ) -> PushTokenRead:
        token = payload.token.strip()
        if not token:
            raise HTTPException(status_code=422, detail="Token invalido")

        row = self.push_tokens.upsert(actor.user.id, token, payload.platform.strip() or "android")
        self.db.commit()
        self.db.refresh(row)
        return PushTokenRead.model_validate(row)
