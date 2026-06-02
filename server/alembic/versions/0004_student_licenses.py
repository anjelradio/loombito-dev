"""add student licenses table

Revision ID: 0004_student_licenses
Revises: 0003_comm_notifications
Create Date: 2026-05-27 00:00:02.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "0004_student_licenses"
down_revision: Union[str, Sequence[str], None] = "0003_comm_notifications"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "student_licenses",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("school_id", sa.Uuid(), nullable=False),
        sa.Column("student_id", sa.Uuid(), nullable=False),
        sa.Column("author_user_id", sa.Uuid(), nullable=False),
        sa.Column("reason", sa.String(length=40), nullable=False),
        sa.Column("description", sa.String(length=1200), nullable=False),
        sa.Column("start_date", sa.Date(), nullable=False),
        sa.Column("end_date", sa.Date(), nullable=False),
        sa.ForeignKeyConstraint(["author_user_id"], ["user.id"]),
        sa.ForeignKeyConstraint(["school_id"], ["school.id"]),
        sa.ForeignKeyConstraint(["student_id"], ["students.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_student_licenses_school_id", "student_licenses", ["school_id"], unique=False)
    op.create_index("ix_student_licenses_student_id", "student_licenses", ["student_id"], unique=False)
    op.create_index("ix_student_licenses_author_user_id", "student_licenses", ["author_user_id"], unique=False)
    op.create_index("ix_student_licenses_reason", "student_licenses", ["reason"], unique=False)
    op.create_index(
        "ix_student_licenses_student_created",
        "student_licenses",
        ["student_id", "created_date"],
        unique=False,
    )
    op.create_index(
        "ix_student_licenses_school_created",
        "student_licenses",
        ["school_id", "created_date"],
        unique=False,
    )
    op.create_index(
        "ix_student_licenses_student_active",
        "student_licenses",
        ["student_id"],
        unique=False,
        sqlite_where=sa.text("state = 1"),
        postgresql_where=sa.text("state = true"),
    )


def downgrade() -> None:
    op.drop_index("ix_student_licenses_student_active", table_name="student_licenses")
    op.drop_index("ix_student_licenses_school_created", table_name="student_licenses")
    op.drop_index("ix_student_licenses_student_created", table_name="student_licenses")
    op.drop_index("ix_student_licenses_reason", table_name="student_licenses")
    op.drop_index("ix_student_licenses_author_user_id", table_name="student_licenses")
    op.drop_index("ix_student_licenses_student_id", table_name="student_licenses")
    op.drop_index("ix_student_licenses_school_id", table_name="student_licenses")
    op.drop_table("student_licenses")
