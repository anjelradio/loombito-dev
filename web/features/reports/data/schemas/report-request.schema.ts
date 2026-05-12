import { z } from "zod";

export const ExportEvaluationReportSchema = z.object({
  schoolId: z.uuid(),
  assignmentId: z.uuid().optional(),
  evaluationId: z.uuid().optional(),
  columns: z.array(z.string().min(1)).min(1, "Selecciona al menos una columna"),
  format: z.enum(["xlsx", "pdf"]),
  summary: z.string().max(240).optional().nullable(),
}).refine((data) => !!data.assignmentId || !!data.evaluationId, {
  message: "Debes enviar assignmentId o evaluationId",
  path: ["assignmentId"],
});

export type ExportEvaluationReportData = z.infer<typeof ExportEvaluationReportSchema>;

export const ExportAttendanceReportSchema = z.object({
  schoolId: z.uuid(),
  assignmentId: z.uuid(),
  fromDate: z.string().optional(),
  toDate: z.string().optional(),
  mode: z.enum(["general", "student_specific"]),
  studentLastName: z.string().max(80).optional(),
  studentFirstName: z.string().max(80).optional(),
  attendanceStatusFilter: z.enum(["all", "presente", "falta", "licencia"]).optional(),
  columns: z.array(z.string().min(1)).min(1, "Selecciona al menos una columna"),
  format: z.enum(["xlsx", "pdf"]),
  summary: z.string().max(240).optional().nullable(),
}).refine((data) => {
  if (data.mode === "general") return true;
  return Boolean((data.studentLastName || "").trim() || (data.studentFirstName || "").trim());
}, {
  message: "En modo especifico debes indicar apellido y/o nombre",
  path: ["studentLastName"],
});

export type ExportAttendanceReportData = z.infer<typeof ExportAttendanceReportSchema>;
