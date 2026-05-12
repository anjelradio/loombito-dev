import { z } from "zod";

export const ReportRunResponseSchema = z.object({
  id: z.uuid(),
  school_id: z.uuid(),
  report_type: z.enum(["attendance_report", "evaluation_gradebook_report", "term_average_report"]),
  filters_json: z.record(z.string(), z.unknown()),
  columns_json: z.array(z.string()),
  format: z.enum(["xlsx", "pdf"]),
  summary: z.string().nullable(),
  created_date: z.string(),
});

export const ReportEvaluationOptionResponseSchema = z.object({
  id: z.uuid(),
  name: z.string(),
});

export const ReportEvaluationOptionsResponseSchema = z.object({
  options: z.array(ReportEvaluationOptionResponseSchema),
});

export type ReportRunResponseDto = z.infer<typeof ReportRunResponseSchema>;
export type ReportEvaluationOptionResponseDto = z.infer<typeof ReportEvaluationOptionResponseSchema>;
export type ReportEvaluationOptionsResponseDto = z.infer<typeof ReportEvaluationOptionsResponseSchema>;
