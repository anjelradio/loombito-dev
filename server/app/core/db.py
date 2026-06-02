from typing import Iterator

from sqlmodel import Session, create_engine

from app.core import models_registry  # noqa: F401
from app.core.config import settings

engine = create_engine(
    settings.DATABASE_URL_NORMALIZED,
    echo=False,
    connect_args={"check_same_thread": False}
    if "sqlite" in settings.DATABASE_URL_NORMALIZED
    else {},
    pool_pre_ping=True,
)


def get_session() -> Iterator[Session]:
    with Session(engine) as session:
        yield session
