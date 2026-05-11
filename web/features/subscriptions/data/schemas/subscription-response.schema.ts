import { z } from "zod";

export const CurrentSubscriptionResponseSchema = z.object({
  school_id: z.uuid(),
  plan_code: z.enum(["free", "professional", "institutional"]),
  plan_name: z.string(),
  price_amount: z.number(),
  currency: z.string(),
  billing_cycle: z.enum(["monthly"]),
  status: z.enum(["active", "canceled", "past_due"]),
  current_period_end: z.string().nullable(),
});

export type CurrentSubscriptionResponseDto = z.infer<typeof CurrentSubscriptionResponseSchema>;

export const CheckoutSessionResponseSchema = z.object({
  checkout_url: z.url(),
  session_id: z.string(),
});

export type CheckoutSessionResponseDto = z.infer<typeof CheckoutSessionResponseSchema>;
