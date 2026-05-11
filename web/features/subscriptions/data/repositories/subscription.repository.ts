import { subscriptionApi } from "../api/subscription-api";

export const subscriptionRepository = {
  createCheckoutSession(
    schoolId: string,
    planCode: "professional" | "institutional",
  ) {
    return subscriptionApi.createCheckoutSession(schoolId, planCode);
  },

  getCurrentSubscription(schoolId: string) {
    return subscriptionApi.getCurrentSubscription(schoolId);
  },

  syncCheckoutSession(sessionId: string) {
    return subscriptionApi.syncCheckoutSession(sessionId);
  },

  cancelSubscription(schoolId: string) {
    return subscriptionApi.cancelSubscription(schoolId);
  },
};
