import { z } from "zod";

export const AuditLogItemResponseSchema = z.object({
  id: z.uuid(),
  created_date: z.string(),
  scope: z.enum(["system", "school"]),
  action: z.string(),
  status: z.enum(["success", "failed"]),
  actor_user_id: z.uuid().nullable(),
  actor_identifier: z.string().nullable(),
  school_id: z.uuid().nullable(),
  description: z.string(),
  ip: z.string(),
});

export const AuditLogListResponseSchema = z.object({
  logs: z.array(AuditLogItemResponseSchema),
  page: z.number(),
  per_page: z.number(),
  total_pages: z.number(),
  has_prev: z.boolean(),
  has_next: z.boolean(),
});

export const RequestAuditAccessResponseSchema = z.object({
  message: z.string(),
  expires_in_seconds: z.number(),
});

export const VerifyAuditAccessResponseSchema = z.object({
  message: z.string(),
  session_expires_in_seconds: z.number(),
});

export type AuditLogItemResponseDto = z.infer<typeof AuditLogItemResponseSchema>;
export type AuditLogListResponseDto = z.infer<typeof AuditLogListResponseSchema>;
