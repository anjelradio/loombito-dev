import { z } from "zod";

export const PaymentConceptCreateSchema = z.object({
  name: z.string().min(1, "El nombre es obligatorio"),
  amount: z.coerce.number().min(0, "El monto debe ser mayor o igual a 0"),
  is_recurring: z.boolean().default(true),
});

export const PaymentConceptUpdateSchema = z.object({
  name: z.string().min(1, "El nombre es obligatorio").optional(),
  amount: z.coerce.number().min(0, "El monto debe ser mayor o igual a 0").optional(),
  is_recurring: z.boolean().optional(),
});
