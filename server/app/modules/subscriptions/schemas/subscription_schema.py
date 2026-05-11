from datetime import datetime
from uuid import UUID

from sqlmodel import SQLModel

from app.modules.subscriptions.models import BillingCycle, PlanCode, SubscriptionStatus


class CheckoutSessionCreate(SQLModel):
    school_id: UUID
    plan_code: PlanCode


class CheckoutSessionRead(SQLModel):
    checkout_url: str
    session_id: str


class CurrentSubscriptionRead(SQLModel):
    school_id: UUID
    plan_code: PlanCode
    plan_name: str
    price_amount: float
    currency: str
    billing_cycle: BillingCycle
    status: SubscriptionStatus
    current_period_end: datetime | None


class StripeWebhookRead(SQLModel):
    received: bool
