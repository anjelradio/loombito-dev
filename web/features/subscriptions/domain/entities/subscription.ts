export type CurrentSubscription = {
  schoolId: string;
  planCode: "free" | "professional" | "institutional";
  planName: string;
  priceAmount: number;
  currency: string;
  billingCycle: "monthly";
  status: "active" | "canceled" | "past_due";
  currentPeriodEnd: string | null;
};

export type CheckoutSession = {
  checkoutUrl: string;
  sessionId: string;
};
