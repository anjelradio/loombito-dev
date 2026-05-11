import type {
  CheckoutSession,
  CurrentSubscription,
} from "@/features/subscriptions/domain/entities/subscription";

import type {
  CheckoutSessionResponseDto,
  CurrentSubscriptionResponseDto,
} from "../schemas/subscription-response.schema";

export function toCurrentSubscriptionEntity(dto: CurrentSubscriptionResponseDto): CurrentSubscription {
  return {
    schoolId: dto.school_id,
    planCode: dto.plan_code,
    planName: dto.plan_name,
    priceAmount: dto.price_amount,
    currency: dto.currency,
    billingCycle: dto.billing_cycle,
    status: dto.status,
    currentPeriodEnd: dto.current_period_end,
  };
}

export function toCheckoutSessionEntity(dto: CheckoutSessionResponseDto): CheckoutSession {
  return {
    checkoutUrl: dto.checkout_url,
    sessionId: dto.session_id,
  };
}
