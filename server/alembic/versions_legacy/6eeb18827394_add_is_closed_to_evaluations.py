"""add is_closed to evaluations

Revision ID: 6eeb18827394
Revises: 8fa4b48c510e
Create Date: 2026-05-07 16:52:06.568923

"""
from typing import Sequence, Union
import sqlmodel
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '6eeb18827394'
down_revision: Union[str, Sequence[str], None] = '8fa4b48c510e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    table_names = set(inspector.get_table_names())
    if "evaluations" not in table_names:
        return

    columns = {column["name"] for column in inspector.get_columns("evaluations")}
    if "is_closed" in columns:
        return

    op.add_column(
        "evaluations",
        sa.Column("is_closed", sa.Boolean(), nullable=False, server_default=sa.false()),
    )


def downgrade() -> None:
    """Downgrade schema."""
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    table_names = set(inspector.get_table_names())
    if "evaluations" not in table_names:
        return

    columns = {column["name"] for column in inspector.get_columns("evaluations")}
    if "is_closed" not in columns:
        return

    op.drop_column("evaluations", "is_closed")
