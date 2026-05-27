import { z } from "zod";

export const StudentCreateSchema = z.object({
  firstName: z
    .string()
    .trim()
    .min(3, "El nombre debe tener al menos 3 caracteres")
    .max(50, "El nombre no puede superar los 50 caracteres"),
  lastName: z
    .string()
    .trim()
    .min(3, "El apellido debe tener al menos 3 caracteres")
    .max(50, "El apellido no puede superar los 50 caracteres"),
  birthDate: z.string().min(1, "La fecha de nacimiento es obligatoria"),
});

export const StudentUpdateSchema = StudentCreateSchema;

export const StudentInviteExportSchema = z.object({
  expiresAt: z.string().min(1, "La fecha de expiracion es obligatoria"),
  maxUses: z.coerce.number().int("La cantidad debe ser entera").min(1, "Debe ser al menos 1"),
});

export type StudentCreateData = z.infer<typeof StudentCreateSchema>;
export type StudentUpdateData = z.infer<typeof StudentUpdateSchema>;
export type StudentInviteExportData = z.infer<typeof StudentInviteExportSchema>;
