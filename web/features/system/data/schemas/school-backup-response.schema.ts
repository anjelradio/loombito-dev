import { z } from "zod";

export const SchoolBackupResponseSchema = z.object({
  id: z.uuid(),
  school_id: z.uuid(),
  created_by_user_id: z.uuid(),
  file_name: z.string(),
  file_size_bytes: z.number(),
  checksum_sha256: z.string(),
  status: z.string(),
  created_date: z.string(),
  restored_date: z.string().nullable(),
});

export const SchoolBackupListResponseSchema = z.array(SchoolBackupResponseSchema);

export const CreateSchoolBackupResponseSchema = z.object({
  backup: SchoolBackupResponseSchema,
});

export type SchoolBackupResponseDto = z.infer<typeof SchoolBackupResponseSchema>;
export type SchoolBackupListResponseDto = z.infer<typeof SchoolBackupListResponseSchema>;
export type CreateSchoolBackupResponseDto = z.infer<typeof CreateSchoolBackupResponseSchema>;
