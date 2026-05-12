"""baseline schema from SQLModel metadata

Revision ID: 0001_baseline_schema
Revises:
Create Date: 2026-05-12 23:50:00.000000

"""

from typing import Sequence, Union

from alembic import op
from sqlmodel import SQLModel

from app.core import models_registry  # noqa: F401


# revision identifiers, used by Alembic.
revision: str = "0001_baseline_schema"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    SQLModel.metadata.create_all(bind=bind)


def downgrade() -> None:
    bind = op.get_bind()
    SQLModel.metadata.drop_all(bind=bind)
