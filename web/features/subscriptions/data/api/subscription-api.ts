import { apiRequestJson } from "@/features/shared/infrastructure/api/api-client";
import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import {
  toCheckoutSessionEntity,
  toCurrentSubscriptionEntity,
} from "@/features/subscriptions/data/mappers/subscription.mapper";
import {
  CheckoutSessionResponseSchema,
  CurrentSubscriptionResponseSchema,
} from "@/features/subscriptions/data/schemas/subscription-response.schema";
import type { SubscriptionPlan } from "@/features/subscriptions/domain/entities/plan";
import type {
  CheckoutSession,
  CurrentSubscription,
} from "@/features/subscriptions/domain/entities/subscription";

const baseUrl = `${env.API_URL}/subscriptions`;

export const subscriptionApi = {
  async createCheckoutSession(
    schoolId: string,
    planCode: Exclude<SubscriptionPlan["code"], "free">,
  ): Promise<ApiResult<CheckoutSession>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/checkout-session`,
      method: "POST",
      token,
      body: {
        school_id: schoolId,
        plan_code: planCode,
      },
      fallbackMessage: "No se pudo iniciar el pago.",
      responseSchema: CheckoutSessionResponseSchema,
      mapData: toCheckoutSessionEntity,
    });
  },

  async getCurrentSubscription(schoolId: string): Promise<ApiResult<CurrentSubscription>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/current`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudo obtener el plan actual.",
      responseSchema: CurrentSubscriptionResponseSchema,
      mapData: toCurrentSubscriptionEntity,
    });
  },

  async syncCheckoutSession(sessionId: string): Promise<ApiResult<CurrentSubscription>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/checkout-session/${sessionId}/sync`,
      method: "POST",
      token,
      fallbackMessage: "No se pudo sincronizar el pago con Stripe.",
      responseSchema: CurrentSubscriptionResponseSchema,
      mapData: toCurrentSubscriptionEntity,
    });
  },

  async cancelSubscription(schoolId: string): Promise<ApiResult<CurrentSubscription>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/cancel`,
      method: "POST",
      token,
      fallbackMessage: "No se pudo cancelar la renovacion del plan.",
      responseSchema: CurrentSubscriptionResponseSchema,
      mapData: toCurrentSubscriptionEntity,
    });
  },
};
