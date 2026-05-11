"use server";

import { subscriptionRepository } from "@/features/subscriptions/data/repositories/subscription.repository";

export async function cancelSubscription(schoolId: string) {
  return subscriptionRepository.cancelSubscription(schoolId);
}
