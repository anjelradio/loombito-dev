export type SubscriptionPlan = {
  code: "free" | "professional" | "institutional";
  name: string;
  priceLabel: string;
  billingLabel: string;
  description: string;
  highlights: string[];
  limitations?: string[];
  featured?: boolean;
};
