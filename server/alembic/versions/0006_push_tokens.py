"""add push tokens table

Revision ID: 0006_push_tokens
Revises: 0005_cluster_perf
Create Date: 2026-06-01 22:15:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "0006_push_tokens"
down_revision: Union[str, Sequence[str], None] = "0005_cluster_perf"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "push_tokens",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("token", sa.String(length=255), nullable=False),
        sa.Column("platform", sa.String(length=20), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["user.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("token"),
    )
    op.create_index("ix_push_tokens_user_id", "push_tokens", ["user_id"], unique=False)
    op.create_index("ix_push_tokens_token", "push_tokens", ["token"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_push_tokens_token", table_name="push_tokens")
    op.drop_index("ix_push_tokens_user_id", table_name="push_tokens")
    op.drop_table("push_tokens")
