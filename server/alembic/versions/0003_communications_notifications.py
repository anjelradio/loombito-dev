"""add communications and notifications tables

Revision ID: 0003_communications_notifications
Revises: 0002_student_parent_invites
Create Date: 2026-05-27 00:00:01.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "0003_communications_notifications"
down_revision: Union[str, Sequence[str], None] = "0002_student_parent_invites"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "student_communication",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("school_id", sa.Uuid(), nullable=False),
        sa.Column("student_id", sa.Uuid(), nullable=False),
        sa.Column("author_user_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("body", sa.String(), nullable=False),
        sa.ForeignKeyConstraint(["author_user_id"], ["user.id"]),
        sa.ForeignKeyConstraint(["school_id"], ["school.id"]),
        sa.ForeignKeyConstraint(["student_id"], ["students.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_student_communication_school_id", "student_communication", ["school_id"], unique=False)
    op.create_index("ix_student_communication_student_id", "student_communication", ["student_id"], unique=False)
    op.create_index(
        "ix_student_communication_author_user_id",
        "student_communication",
        ["author_user_id"],
        unique=False,
    )
    op.create_index(
        "ix_student_communication_student_created",
        "student_communication",
        ["student_id", "created_date"],
        unique=False,
    )

    op.create_table(
        "notification",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("recipient_user_id", sa.Uuid(), nullable=False),
        sa.Column("school_id", sa.Uuid(), nullable=False),
        sa.Column("student_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("body", sa.String(), nullable=False),
        sa.Column("is_read", sa.Boolean(), nullable=False),
        sa.Column("read_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["recipient_user_id"], ["user.id"]),
        sa.ForeignKeyConstraint(["school_id"], ["school.id"]),
        sa.ForeignKeyConstraint(["student_id"], ["students.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_notification_recipient_user_id", "notification", ["recipient_user_id"], unique=False)
    op.create_index("ix_notification_school_id", "notification", ["school_id"], unique=False)
    op.create_index("ix_notification_student_id", "notification", ["student_id"], unique=False)
    op.create_index("ix_notification_is_read", "notification", ["is_read"], unique=False)
    op.create_index(
        "ix_notification_recipient_unread_created",
        "notification",
        ["recipient_user_id", "is_read", "created_date"],
        unique=False,
    )
    op.create_index(
        "ix_notification_student_created",
        "notification",
        ["student_id", "created_date"],
        unique=False,
    )
    op.create_index(
        "ix_notification_recipient_active",
        "notification",
        ["recipient_user_id"],
        unique=False,
        sqlite_where=sa.text("state = 1"),
        postgresql_where=sa.text("state = true"),
    )


def downgrade() -> None:
    op.drop_index("ix_notification_recipient_active", table_name="notification")
    op.drop_index("ix_notification_student_created", table_name="notification")
    op.drop_index("ix_notification_recipient_unread_created", table_name="notification")
    op.drop_index("ix_notification_is_read", table_name="notification")
    op.drop_index("ix_notification_student_id", table_name="notification")
    op.drop_index("ix_notification_school_id", table_name="notification")
    op.drop_index("ix_notification_recipient_user_id", table_name="notification")
    op.drop_table("notification")

    op.drop_index("ix_student_communication_student_created", table_name="student_communication")
    op.drop_index("ix_student_communication_author_user_id", table_name="student_communication")
    op.drop_index("ix_student_communication_student_id", table_name="student_communication")
    op.drop_index("ix_student_communication_school_id", table_name="student_communication")
    op.drop_table("student_communication")
