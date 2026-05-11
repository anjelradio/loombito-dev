from datetime import datetime
from typing import Any
from uuid import UUID

from fastapi import HTTPException
from sqlmodel import Session

from app.core.config import settings
from app.modules.auth.models import User
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.subscriptions.models import (
    PaymentStatus,
    Plan,
    PlanCode,
    ProviderType,
    SchoolSubscription,
    SubscriptionPayment,
    SubscriptionStatus,
)
from app.modules.subscriptions.permissions import ensure_owner_in_school
from app.modules.subscriptions.repositories import SubscriptionRepository
from app.modules.subscriptions.schemas import (
    CheckoutSessionCreate,
    CheckoutSessionRead,
    CurrentSubscriptionRead,
    StripeWebhookRead,
)


class SubscriptionService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.subscription = SubscriptionRepository(db)

    # Verifica que la escuela exista y que el usuario sea owner.
    def _ensure_school_and_permissions(self, school_id: UUID, user_id: UUID):
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")
        ensure_owner_in_school(self.school_user, user_id, school_id)
        return school

    # Obtiene la suscripcion actual de la escuela para mostrar plan vigente.
    def get_current_subscription(self, school_id: UUID, user_id: UUID) -> CurrentSubscriptionRead:
        self._ensure_school_and_permissions(school_id, user_id)

        row = self.subscription.get_current_subscription_with_plan(school_id)
        if not row:
            raise HTTPException(status_code=404, detail="No se encontro una suscripcion activa")

        subscription, plan = row
        return CurrentSubscriptionRead(
            school_id=school_id,
            plan_code=plan.code,
            plan_name=plan.name,
            price_amount=plan.price_amount,
            currency=plan.currency,
            billing_cycle=plan.billing_cycle,
            status=subscription.status,
            current_period_end=subscription.current_period_end,
        )

    def create_checkout_session(
        self, payload: CheckoutSessionCreate, user: User
    ) -> CheckoutSessionRead:
        self._ensure_school_and_permissions(payload.school_id, user.id)

        if payload.plan_code == PlanCode.FREE:
            raise HTTPException(
                status_code=400,
                detail="El plan esencial no requiere pago.",
            )

        plan = self.subscription.get_active_plan_by_code(payload.plan_code)
        if not plan:
            raise HTTPException(status_code=404, detail="Plan no encontrado")

        current_subscription = self.subscription.get_current_subscription_by_school_id(
            payload.school_id
        )
        if current_subscription and current_subscription.plan_id == plan.id:
            if current_subscription.status == SubscriptionStatus.ACTIVE:
                raise HTTPException(
                    status_code=409,
                    detail="La escuela ya tiene este plan activo.",
                )

        stripe = self._get_stripe()
        metadata = {
            "school_id": str(payload.school_id),
            "plan_code": payload.plan_code.value,
            "user_id": str(user.id),
        }

        try:
            session = stripe.checkout.Session.create(
                mode="subscription",
                payment_method_types=["card"],
                customer_email=user.email,
                client_reference_id=str(payload.school_id),
                line_items=[self._build_checkout_line_item(plan)],
                metadata=metadata,
                subscription_data={"metadata": metadata},
                success_url=self._checkout_success_url(payload.school_id),
                cancel_url=self._checkout_cancel_url(payload.school_id),
                allow_promotion_codes=True,
            )
        except Exception as error:
            raise HTTPException(
                status_code=502,
                detail=f"No se pudo crear la sesion de pago: {error}",
            )

        checkout_url = self._stripe_get(session, "url")
        session_id = self._stripe_get(session, "id")
        if not checkout_url or not session_id:
            raise HTTPException(
                status_code=502,
                detail="Stripe no devolvio una URL de pago valida.",
            )

        return CheckoutSessionRead(checkout_url=checkout_url, session_id=session_id)

    def sync_checkout_session(
        self, session_id: str, user_id: UUID
    ) -> CurrentSubscriptionRead:
        stripe = self._get_stripe()
        try:
            session = stripe.checkout.Session.retrieve(session_id)
        except Exception as error:
            raise HTTPException(
                status_code=502,
                detail=f"No se pudo verificar la sesion de Stripe: {error}",
            )

        metadata = self._stripe_get(session, "metadata") or {}
        school_id_value = self._stripe_get(metadata, "school_id")
        metadata_user_id = self._stripe_get(metadata, "user_id")

        if not school_id_value or not metadata_user_id:
            raise HTTPException(
                status_code=400,
                detail="La sesion de pago no contiene los datos necesarios.",
            )

        if str(metadata_user_id) != str(user_id):
            raise HTTPException(
                status_code=403,
                detail="La sesion de pago no pertenece al usuario actual.",
            )

        status = self._stripe_get(session, "status")
        payment_status = self._stripe_get(session, "payment_status")
        if status != "complete" or payment_status not in {
            "paid",
            "no_payment_required",
        }:
            raise HTTPException(
                status_code=409,
                detail="El pago aun no fue confirmado por Stripe.",
            )

        school_id = UUID(str(school_id_value))
        self._ensure_school_and_permissions(school_id, user_id)
        self._handle_checkout_completed(session, stripe)
        return self.get_current_subscription(school_id, user_id)

    def cancel_subscription(self, school_id: UUID, user_id: UUID) -> CurrentSubscriptionRead:
        self._ensure_school_and_permissions(school_id, user_id)

        row = self.subscription.get_current_subscription_with_plan(school_id)
        if not row:
            raise HTTPException(status_code=404, detail="No se encontro una suscripcion activa")

        current_subscription, plan = row
        if plan.code == PlanCode.FREE:
            raise HTTPException(
                status_code=400,
                detail="El plan esencial no se puede cancelar.",
            )

        if current_subscription.status == SubscriptionStatus.CANCELED:
            return self.get_current_subscription(school_id, user_id)

        if (
            current_subscription.provider == ProviderType.STRIPE
            and current_subscription.provider_subscription_id
        ):
            stripe = self._get_stripe()
            try:
                stripe.Subscription.modify(
                    current_subscription.provider_subscription_id,
                    cancel_at_period_end=True,
                )
            except Exception as error:
                raise HTTPException(
                    status_code=502,
                    detail=f"No se pudo cancelar la renovacion en Stripe: {error}",
                )

        current_subscription.status = SubscriptionStatus.CANCELED
        current_subscription.end_date = current_subscription.current_period_end or datetime.utcnow()
        self.subscription.update_school_subscription(current_subscription)
        self.db.commit()
        self.db.refresh(current_subscription)

        return CurrentSubscriptionRead(
            school_id=school_id,
            plan_code=plan.code,
            plan_name=plan.name,
            price_amount=plan.price_amount,
            currency=plan.currency,
            billing_cycle=plan.billing_cycle,
            status=current_subscription.status,
            current_period_end=current_subscription.current_period_end,
        )

    def handle_stripe_webhook(
        self, payload: bytes, signature: str | None
    ) -> StripeWebhookRead:
        if not signature:
            raise HTTPException(status_code=400, detail="Firma de Stripe ausente")

        if not settings.STRIPE_WEBHOOK_SECRET:
            raise HTTPException(
                status_code=500,
                detail="STRIPE_WEBHOOK_SECRET no esta configurado.",
            )

        stripe = self._get_stripe()
        try:
            event = stripe.Webhook.construct_event(
                payload, signature, settings.STRIPE_WEBHOOK_SECRET
            )
        except ValueError:
            raise HTTPException(status_code=400, detail="Payload de Stripe invalido")
        except stripe.error.SignatureVerificationError:
            raise HTTPException(status_code=400, detail="Firma de Stripe invalida")

        event_type = self._stripe_get(event, "type")
        data = self._stripe_get(event, "data") or {}
        event_object = self._stripe_get(data, "object")

        if event_type == "checkout.session.completed":
            self._handle_checkout_completed(event_object, stripe)
        elif event_type == "invoice.paid":
            self._handle_invoice_paid(event_object)
        elif event_type in {
            "customer.subscription.updated",
            "customer.subscription.deleted",
        }:
            self._handle_subscription_changed(event_object, event_type)

        return StripeWebhookRead(received=True)

    def _get_stripe(self):
        try:
            import stripe
        except ImportError:
            raise HTTPException(
                status_code=500,
                detail="La dependencia stripe no esta instalada en el backend.",
            )

        if not settings.STRIPE_SECRET_KEY:
            raise HTTPException(
                status_code=500,
                detail="STRIPE_SECRET_KEY no esta configurado.",
            )

        stripe.api_key = settings.STRIPE_SECRET_KEY
        return stripe

    def _build_checkout_line_item(self, plan: Plan) -> dict[str, Any]:
        price_id = self._stripe_price_id_for_plan(plan.code)
        if price_id:
            return {"price": price_id, "quantity": 1}

        return {
            "price_data": {
                "currency": plan.currency.lower(),
                "product_data": {"name": f"LoomBo {plan.name}"},
                "unit_amount": int(round(plan.price_amount * 100)),
                "recurring": {"interval": "month"},
            },
            "quantity": 1,
        }

    def _stripe_price_id_for_plan(self, plan_code: PlanCode) -> str:
        if plan_code == PlanCode.PROFESSIONAL:
            return settings.STRIPE_PRICE_ID_PROFESSIONAL
        if plan_code == PlanCode.INSTITUTIONAL:
            return settings.STRIPE_PRICE_ID_INSTITUTIONAL
        return ""

    def _checkout_success_url(self, school_id: UUID) -> str:
        base_url = settings.APP_BASE_URL.rstrip("/")
        return (
            f"{base_url}/inicio/planes/success?"
            f"schoolId={school_id}&session_id={{CHECKOUT_SESSION_ID}}"
        )

    def _checkout_cancel_url(self, school_id: UUID) -> str:
        base_url = settings.APP_BASE_URL.rstrip("/")
        return f"{base_url}/inicio/planes?schoolId={school_id}&canceled=1"

    def _handle_checkout_completed(self, session: Any, stripe: Any) -> None:
        metadata = self._stripe_get(session, "metadata") or {}
        school_id_value = self._stripe_get(metadata, "school_id")
        plan_code_value = self._stripe_get(metadata, "plan_code")
        subscription_id = self._optional_stripe_id(
            self._stripe_get(session, "subscription")
        )
        customer_id = self._optional_stripe_id(self._stripe_get(session, "customer"))

        if not school_id_value or not plan_code_value or not subscription_id:
            return

        school_id = UUID(str(school_id_value))
        plan_code = PlanCode(str(plan_code_value))
        plan = self.subscription.get_active_plan_by_code(plan_code)
        if not plan:
            return

        stripe_subscription = stripe.Subscription.retrieve(subscription_id)
        period_start = self._datetime_from_timestamp(
            self._stripe_get(stripe_subscription, "current_period_start")
        )
        period_end = self._datetime_from_timestamp(
            self._stripe_get(stripe_subscription, "current_period_end")
        )

        existing = self.subscription.get_subscription_by_provider_subscription_id(
            subscription_id
        )
        if existing:
            existing.status = SubscriptionStatus.ACTIVE
            existing.current_period_start = period_start
            existing.current_period_end = period_end
            existing.provider_customer_id = str(customer_id) if customer_id else None
            self.subscription.update_school_subscription(existing)
            self.db.flush()
            self._record_checkout_payment(session, existing)
            self.db.commit()
            return

        current_subscription = self.subscription.get_current_subscription_by_school_id(
            school_id
        )
        if current_subscription:
            self.subscription.deactivate_current_subscription(current_subscription)

        new_subscription = SchoolSubscription(
            school_id=school_id,
            plan_id=plan.id,
            status=SubscriptionStatus.ACTIVE,
            current_period_start=period_start,
            current_period_end=period_end,
            provider=ProviderType.STRIPE,
            provider_subscription_id=str(subscription_id),
            provider_customer_id=str(customer_id) if customer_id else None,
        )
        self.subscription.create_school_subscription(new_subscription)
        self.db.flush()
        self._record_checkout_payment(session, new_subscription)
        self.db.commit()

    def _handle_invoice_paid(self, invoice: Any) -> None:
        invoice_id = self._stripe_get(invoice, "id")
        if invoice_id and self.subscription.get_payment_by_provider_invoice_id(invoice_id):
            return

        subscription_id = self._optional_stripe_id(
            self._stripe_get(invoice, "subscription")
        )
        if not subscription_id:
            return

        school_subscription = self.subscription.get_subscription_by_provider_subscription_id(
            subscription_id
        )
        if not school_subscription:
            return

        amount_paid = self._stripe_get(invoice, "amount_paid") or 0
        currency = (self._stripe_get(invoice, "currency") or "bob").upper()
        paid_at = self._datetime_from_timestamp(
            self._stripe_get(self._stripe_get(invoice, "status_transitions") or {}, "paid_at")
        )

        self.subscription.create_subscription_payment(
            SubscriptionPayment(
                school_subscription_id=school_subscription.id,
                amount=float(amount_paid) / 100,
                currency=currency,
                status=PaymentStatus.PAID,
                payment_method="card",
                paid_at=paid_at or datetime.utcnow(),
                provider_invoice_id=str(invoice_id) if invoice_id else None,
                provider_payment_intent_id=self._optional_stripe_id(
                    self._stripe_get(invoice, "payment_intent")
                ),
            )
        )
        self.db.commit()

    def _handle_subscription_changed(self, subscription: Any, event_type: str) -> None:
        subscription_id = self._stripe_get(subscription, "id")
        if not subscription_id:
            return

        school_subscription = self.subscription.get_subscription_by_provider_subscription_id(
            subscription_id
        )
        if not school_subscription:
            return

        cancel_at_period_end = bool(
            self._stripe_get(subscription, "cancel_at_period_end")
        )
        school_subscription.status = (
            SubscriptionStatus.CANCELED
            if event_type == "customer.subscription.deleted" or cancel_at_period_end
            else self._map_stripe_subscription_status(
                self._stripe_get(subscription, "status")
            )
        )
        school_subscription.current_period_start = self._datetime_from_timestamp(
            self._stripe_get(subscription, "current_period_start")
        )
        school_subscription.current_period_end = self._datetime_from_timestamp(
            self._stripe_get(subscription, "current_period_end")
        )
        if school_subscription.status == SubscriptionStatus.CANCELED:
            school_subscription.end_date = (
                school_subscription.current_period_end or datetime.utcnow()
            )

        self.subscription.update_school_subscription(school_subscription)
        self.db.commit()

    def _record_checkout_payment(
        self, session: Any, school_subscription: SchoolSubscription
    ) -> None:
        invoice_id = self._optional_stripe_id(self._stripe_get(session, "invoice"))
        if invoice_id and self.subscription.get_payment_by_provider_invoice_id(invoice_id):
            return

        amount_total = self._stripe_get(session, "amount_total") or 0
        currency = (self._stripe_get(session, "currency") or "bob").upper()
        payment_intent_id = self._optional_stripe_id(
            self._stripe_get(session, "payment_intent")
        )

        self.subscription.create_subscription_payment(
            SubscriptionPayment(
                school_subscription_id=school_subscription.id,
                amount=float(amount_total) / 100,
                currency=currency,
                status=PaymentStatus.PAID,
                payment_method="card",
                paid_at=datetime.utcnow(),
                provider_invoice_id=str(invoice_id) if invoice_id else None,
                provider_payment_intent_id=payment_intent_id,
            )
        )

    def _map_stripe_subscription_status(
        self, stripe_status: str | None
    ) -> SubscriptionStatus:
        if stripe_status in {"active", "trialing"}:
            return SubscriptionStatus.ACTIVE
        if stripe_status in {"canceled", "incomplete_expired"}:
            return SubscriptionStatus.CANCELED
        return SubscriptionStatus.PAST_DUE

    def _datetime_from_timestamp(self, value: Any) -> datetime | None:
        if value is None:
            return None
        try:
            return datetime.utcfromtimestamp(int(value))
        except (TypeError, ValueError, OSError):
            return None

    def _optional_stripe_id(self, value: Any) -> str | None:
        if value is None:
            return None
        if isinstance(value, str):
            return value
        stripe_id = self._stripe_get(value, "id")
        return str(stripe_id) if stripe_id else None

    def _stripe_get(self, value: Any, key: str) -> Any:
        if value is None:
            return None
        if isinstance(value, dict):
            return value.get(key)
        if hasattr(value, "get"):
            try:
                return value.get(key)
            except Exception:
                pass
        return getattr(value, key, None)
