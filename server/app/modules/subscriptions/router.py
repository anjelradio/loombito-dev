from uuid import UUID

from fastapi import APIRouter, Header, Request

from app.dependencies.auth import CurrentUser, DBSession
from app.modules.subscriptions.schemas import (
    CheckoutSessionCreate,
    CheckoutSessionRead,
    CurrentSubscriptionRead,
    StripeWebhookRead,
)
from app.modules.subscriptions.services import SubscriptionService

router = APIRouter(prefix="/subscriptions", tags=["Suscripciones"])


@router.post("/checkout-session", response_model=CheckoutSessionRead)
def create_checkout_session(
    payload: CheckoutSessionCreate,
    db: DBSession,
    user: CurrentUser,
):
    return SubscriptionService(db).create_checkout_session(payload, user)


@router.get("/schools/{school_id}/current", response_model=CurrentSubscriptionRead)
def get_current_subscription(school_id: UUID, db: DBSession, user: CurrentUser):
    return SubscriptionService(db).get_current_subscription(school_id, user.id)


@router.post(
    "/checkout-session/{session_id}/sync",
    response_model=CurrentSubscriptionRead,
)
def sync_checkout_session(session_id: str, db: DBSession, user: CurrentUser):
    return SubscriptionService(db).sync_checkout_session(session_id, user.id)


@router.post("/schools/{school_id}/cancel", response_model=CurrentSubscriptionRead)
def cancel_subscription(school_id: UUID, db: DBSession, user: CurrentUser):
    return SubscriptionService(db).cancel_subscription(school_id, user.id)


@router.post("/webhook/stripe", response_model=StripeWebhookRead)
async def stripe_webhook(
    request: Request,
    db: DBSession,
    stripe_signature: str | None = Header(default=None),
):
    payload = await request.body()
    return SubscriptionService(db).handle_stripe_webhook(payload, stripe_signature)
