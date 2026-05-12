from dataclasses import dataclass
from typing import Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, Request
from fastapi.security import OAuth2PasswordBearer
from sqlmodel import Session

from app.core.db import get_session
from app.core.security import decode_token
from app.modules.auth.models import User
from app.modules.auth.repositories import UserRepository

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/token")


def get_db():
    yield from get_session()


DBSession = Annotated[Session, Depends(get_db)]


def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)], db: DBSession
) -> User:
    credentials_exc = HTTPException(
        status_code=401, detail="No Autorizado", headers={"WWW-Authenticate": "Bearer"}
    )
    try:
        payload = decode_token(token)
        user_id = UUID(payload.get("sub"))
    except Exception:
        raise credentials_exc

    repo = UserRepository(db)
    user = repo.get_by_id(user_id)

    if not user:
        raise credentials_exc

    return user


CurrentUser = Annotated[User, Depends(get_current_user)]


@dataclass
class RequestActor:
    ip: str
    user_agent: str | None


def get_request_actor(request: Request) -> RequestActor:
    ip = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent")
    return RequestActor(ip=ip, user_agent=user_agent)


CurrentRequestActor = Annotated[RequestActor, Depends(get_request_actor)]


@dataclass
class CurrentActorContext:
    user: User
    ip: str
    user_agent: str | None


def get_current_actor(user: CurrentUser, request_actor: CurrentRequestActor) -> CurrentActorContext:
    return CurrentActorContext(
        user=user,
        ip=request_actor.ip,
        user_agent=request_actor.user_agent,
    )


CurrentActor = Annotated[CurrentActorContext, Depends(get_current_actor)]
