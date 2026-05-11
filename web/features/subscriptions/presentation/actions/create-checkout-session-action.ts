"use server";

import { subscriptionRepository } from "@/features/subscriptions/data/repositories/subscription.repository";

export async function createCheckoutSession(
  schoolId: string,
  planCode: "professional" | "institutional",
) {
  return subscriptionRepository.createCheckoutSession(schoolId, planCode);
}
