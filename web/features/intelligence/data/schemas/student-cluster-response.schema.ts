import { z } from "zod";

export const StudentClusterRowResponseSchema = z.object({
  student_id: z.uuid(),
  first_name: z.string(),
  last_name: z.string(),
  cluster_id: z.number(),
  cluster_label: z.enum(["alto_rendimiento", "rendimiento_medio", "en_riesgo"]),
  final_score: z.number(),
  attendance_rate: z.number(),
});

export const StudentClusterSnapshotResponseSchema = z.object({
  assignment_id: z.uuid(),
  term_id: z.uuid(),
  school_id: z.uuid(),
  features_version: z.string().nullable(),
  k_value: z.number().nullable(),
  inertia: z.number().nullable(),
  silhouette_score: z.number().nullable(),
  trained_at: z.string().nullable(),
  students: z.array(StudentClusterRowResponseSchema),
});

export type StudentClusterRowResponseDto = z.infer<typeof StudentClusterRowResponseSchema>;
export type StudentClusterSnapshotResponseDto = z.infer<typeof StudentClusterSnapshotResponseSchema>;
