"""add student parent and invite tables

Revision ID: 0002_student_parent_invites
Revises: 0001_baseline_schema
Create Date: 2026-05-27 00:00:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "0002_student_parent_invites"
down_revision: Union[str, Sequence[str], None] = "0001_baseline_schema"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "student_parent",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("student_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(["student_id"], ["students.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["user.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_student_parent_user_id", "student_parent", ["user_id"], unique=False)
    op.create_index("ix_student_parent_student_id", "student_parent", ["student_id"], unique=False)
    op.create_index(
        "uq_student_parent_pair_active",
        "student_parent",
        ["user_id", "student_id"],
        unique=True,
        sqlite_where=sa.text("state = 1"),
        postgresql_where=sa.text("state = true"),
    )

    op.create_table(
        "student_parent_invite",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("code", sa.String(), nullable=False),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("max_uses", sa.Integer(), nullable=False),
        sa.Column("used_count", sa.Integer(), nullable=False),
        sa.Column("student_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(["student_id"], ["students.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_student_parent_invite_student_id",
        "student_parent_invite",
        ["student_id"],
        unique=False,
    )
    op.create_index("ix_student_parent_invite_code", "student_parent_invite", ["code"], unique=False)
    op.create_index(
        "uq_student_parent_invite_code_active",
        "student_parent_invite",
        ["code"],
        unique=True,
        sqlite_where=sa.text("state = 1"),
        postgresql_where=sa.text("state = true"),
    )
    op.create_index(
        "uq_student_parent_invite_student_active",
        "student_parent_invite",
        ["student_id"],
        unique=True,
        sqlite_where=sa.text("state = 1"),
        postgresql_where=sa.text("state = true"),
    )


def downgrade() -> None:
    op.drop_index("uq_student_parent_invite_student_active", table_name="student_parent_invite")
    op.drop_index("uq_student_parent_invite_code_active", table_name="student_parent_invite")
    op.drop_index("ix_student_parent_invite_code", table_name="student_parent_invite")
    op.drop_index("ix_student_parent_invite_student_id", table_name="student_parent_invite")
    op.drop_table("student_parent_invite")

    op.drop_index("uq_student_parent_pair_active", table_name="student_parent")
    op.drop_index("ix_student_parent_student_id", table_name="student_parent")
    op.drop_index("ix_student_parent_user_id", table_name="student_parent")
    op.drop_table("student_parent")
