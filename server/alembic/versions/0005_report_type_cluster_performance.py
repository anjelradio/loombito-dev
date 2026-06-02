"""add cluster performance report type enum value

Revision ID: 0005_cluster_perf
Revises: 0004_student_licenses
Create Date: 2026-06-01 19:30:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "0005_cluster_perf"
down_revision: Union[str, Sequence[str], None] = "0004_student_licenses"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute(
            sa.text(
                """
                DO $$
                BEGIN
                    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'reporttype') THEN
                        ALTER TYPE reporttype ADD VALUE IF NOT EXISTS 'CLUSTER_PERFORMANCE';
                    END IF;
                END
                $$;
                """
            )
        )


def downgrade() -> None:
    pass
