"""add school backups table

Revision ID: 9f1b2c3d4e5f
Revises: 5dc3fe56a42c
Create Date: 2026-05-12 10:30:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "9f1b2c3d4e5f"
down_revision: Union[str, Sequence[str], None] = "5dc3fe56a42c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "school_backups",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("school_id", sa.Uuid(), nullable=False),
        sa.Column("created_by_user_id", sa.Uuid(), nullable=False),
        sa.Column("file_name", sa.String(length=255), nullable=False),
        sa.Column("file_path", sa.String(length=1000), nullable=False),
        sa.Column("file_size_bytes", sa.Integer(), nullable=False),
        sa.Column("checksum_sha256", sa.String(length=128), nullable=False),
        sa.Column("status", sa.String(length=30), nullable=False),
        sa.Column("restored_date", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["school_id"], ["school.id"]),
        sa.ForeignKeyConstraint(["created_by_user_id"], ["user.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_school_backups_school_id"), "school_backups", ["school_id"], unique=False)
    op.create_index(
        op.f("ix_school_backups_created_by_user_id"),
        "school_backups",
        ["created_by_user_id"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_school_backups_created_by_user_id"), table_name="school_backups")
    op.drop_index(op.f("ix_school_backups_school_id"), table_name="school_backups")
    op.drop_table("school_backups")
