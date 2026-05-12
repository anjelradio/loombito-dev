import { z } from "zod";

import { SchoolRoleEnum, SchoolTypeEnum } from "../shared/school-enums.schema";

export const SchoolResponseSchema = z.object({
  id: z.uuid(),
  name: z.string(),
  logo_image: z.string().nullable(),
  type: SchoolTypeEnum,
  phone: z.string(),
  role: SchoolRoleEnum.optional(),
});

export const SchoolResponseListSchema = z.array(SchoolResponseSchema);

export const SchoolDirectoryResponseSchema = z.object({
  schools: z.array(SchoolResponseSchema),
  page: z.number(),
  per_page: z.number(),
  total: z.number(),
  total_pages: z.number(),
  has_prev: z.boolean(),
  has_next: z.boolean(),
});

export type SchoolResponseDto = z.infer<typeof SchoolResponseSchema>;
export type SchoolResponseListDto = z.infer<typeof SchoolResponseListSchema>;
export type SchoolDirectoryResponseDto = z.infer<typeof SchoolDirectoryResponseSchema>;
