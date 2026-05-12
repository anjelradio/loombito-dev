"""add subscriptions module tables

Revision ID: fc2d0cc5cf69
Revises: 85ab8db9bec9
Create Date: 2026-05-08 17:42:27.116007

"""
import sqlalchemy as sa
from alembic import op
from typing import Sequence, Union


# revision identifiers, used by Alembic.
revision: str = 'fc2d0cc5cf69'
down_revision: Union[str, Sequence[str], None] = '85ab8db9bec9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not inspector.has_table("plans"):
        op.create_table(
        "plans",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("code", sa.Enum("FREE", "PROFESSIONAL", "INSTITUTIONAL", name="plancode"), nullable=False),
        sa.Column("name", sa.String(length=50), nullable=False),
        sa.Column("price_amount", sa.Float(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("billing_cycle", sa.Enum("MONTHLY", name="billingcycle"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        )
    if "ix_plans_code" not in [idx["name"] for idx in inspector.get_indexes("plans")]:
        op.create_index("ix_plans_code", "plans", ["code"], unique=False)
    if "uq_plans_code_active" not in [idx["name"] for idx in inspector.get_indexes("plans")]:
        op.create_index(
            "uq_plans_code_active",
            "plans",
            ["code"],
            unique=True,
            sqlite_where=sa.text("state = 1"),
        )

    if not inspector.has_table("school_subscriptions"):
        op.create_table(
        "school_subscriptions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("school_id", sa.Uuid(), nullable=False),
        sa.Column("plan_id", sa.Uuid(), nullable=False),
        sa.Column("status", sa.Enum("ACTIVE", "CANCELED", "PAST_DUE", name="subscriptionstatus"), nullable=False),
        sa.Column("start_date", sa.DateTime(), nullable=False),
        sa.Column("end_date", sa.DateTime(), nullable=True),
        sa.Column("current_period_start", sa.DateTime(), nullable=True),
        sa.Column("current_period_end", sa.DateTime(), nullable=True),
        sa.Column("is_current", sa.Boolean(), nullable=False),
        sa.Column("provider", sa.Enum("INTERNAL", "STRIPE", name="providertype"), nullable=False),
        sa.Column("provider_subscription_id", sa.String(length=120), nullable=True),
        sa.Column("provider_customer_id", sa.String(length=120), nullable=True),
        sa.ForeignKeyConstraint(["plan_id"], ["plans.id"]),
        sa.ForeignKeyConstraint(["school_id"], ["school.id"]),
        sa.PrimaryKeyConstraint("id"),
        )
    school_sub_indexes = [idx["name"] for idx in inspector.get_indexes("school_subscriptions")]
    if "ix_school_subscriptions_plan_id" not in school_sub_indexes:
        op.create_index("ix_school_subscriptions_plan_id", "school_subscriptions", ["plan_id"], unique=False)
    if "ix_school_subscriptions_school_id" not in school_sub_indexes:
        op.create_index("ix_school_subscriptions_school_id", "school_subscriptions", ["school_id"], unique=False)
    if "uq_school_subscriptions_school_current_active" not in school_sub_indexes:
        op.create_index(
            "uq_school_subscriptions_school_current_active",
            "school_subscriptions",
            ["school_id"],
            unique=True,
            sqlite_where=sa.text("state = 1 AND is_current = 1"),
        )

    if not inspector.has_table("subscription_payments"):
        op.create_table(
        "subscription_payments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("state", sa.Boolean(), nullable=False),
        sa.Column("created_date", sa.DateTime(), nullable=False),
        sa.Column("modified_date", sa.DateTime(), nullable=False),
        sa.Column("deleted_date", sa.DateTime(), nullable=True),
        sa.Column("school_subscription_id", sa.Uuid(), nullable=False),
        sa.Column("amount", sa.Float(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("status", sa.Enum("PAID", "FAILED", "PENDING", name="paymentstatus"), nullable=False),
        sa.Column("payment_method", sa.String(length=60), nullable=True),
        sa.Column("paid_at", sa.DateTime(), nullable=True),
        sa.Column("provider_invoice_id", sa.String(length=120), nullable=True),
        sa.Column("provider_payment_intent_id", sa.String(length=120), nullable=True),
        sa.ForeignKeyConstraint(["school_subscription_id"], ["school_subscriptions.id"]),
        sa.PrimaryKeyConstraint("id"),
        )
    subscription_payment_indexes = [idx["name"] for idx in inspector.get_indexes("subscription_payments")]
    if "ix_subscription_payments_school_subscription_id" not in subscription_payment_indexes:
        op.create_index(
            "ix_subscription_payments_school_subscription_id",
            "subscription_payments",
            ["school_subscription_id"],
            unique=False,
        )


def downgrade() -> None:
    """Downgrade schema."""
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if inspector.has_table("subscription_payments"):
        indexes = [idx["name"] for idx in inspector.get_indexes("subscription_payments")]
        if "ix_subscription_payments_school_subscription_id" in indexes:
            op.drop_index("ix_subscription_payments_school_subscription_id", table_name="subscription_payments")
        op.drop_table("subscription_payments")

    if inspector.has_table("school_subscriptions"):
        indexes = [idx["name"] for idx in inspector.get_indexes("school_subscriptions")]
        if "uq_school_subscriptions_school_current_active" in indexes:
            op.drop_index("uq_school_subscriptions_school_current_active", table_name="school_subscriptions")
        if "ix_school_subscriptions_school_id" in indexes:
            op.drop_index("ix_school_subscriptions_school_id", table_name="school_subscriptions")
        if "ix_school_subscriptions_plan_id" in indexes:
            op.drop_index("ix_school_subscriptions_plan_id", table_name="school_subscriptions")
        op.drop_table("school_subscriptions")

    if inspector.has_table("plans"):
        indexes = [idx["name"] for idx in inspector.get_indexes("plans")]
        if "uq_plans_code_active" in indexes:
            op.drop_index("uq_plans_code_active", table_name="plans")
        if "ix_plans_code" in indexes:
            op.drop_index("ix_plans_code", table_name="plans")
        op.drop_table("plans")
