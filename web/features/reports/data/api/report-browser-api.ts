import { parseWithSchema } from "@/features/shared/infrastructure/api/parse-with-schema";
import { errorResult, serverErrorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiResult } from "@/features/shared/infrastructure/types/api-resource";

import type {
  ExportAttendanceReportInput,
  ExportEvaluationReportInput,
  ExportedReportFile,
  ReportEvaluationOption,
} from "../../domain/entities/report";
import {
  toReportEvaluationOptionEntity,
} from "../mappers/report.mapper";
import {
  ExportEvaluationReportSchema,
  ExportAttendanceReportSchema,
} from "../schemas/report-request.schema";
import {
  ReportEvaluationOptionsResponseSchema,
} from "../schemas/report-response.schema";

const fallbackEvaluationOptionsMessage = "No se pudieron cargar las evaluaciones";
const fallbackExportMessage = "No se pudo generar el reporte";
const fallbackAttendanceExportMessage = "No se pudo generar el reporte de asistencia";

export const reportBrowserApi = {
  async getEvaluationOptionsByAssignment(
    schoolId: string,
    assignmentId: string,
  ): Promise<ApiResult<ReportEvaluationOption[]>> {
    try {
      const params = new URLSearchParams();
      params.set("schoolId", schoolId);
      params.set("assignmentId", assignmentId);

      const response = await fetch(`/api/reports/evaluations/by-assignment?${params.toString()}`, {
        method: "GET",
        cache: "no-store",
      });

      if (!response.ok) {
        return serverErrorResult(response, fallbackEvaluationOptionsMessage);
      }

      const payload = await response.json();
      const parsed = ReportEvaluationOptionsResponseSchema.safeParse(payload);
      if (!parsed.success) {
        return errorResult("Error en la respuesta del servidor");
      }

      return {
        ok: true,
        data: parsed.data.options.map(toReportEvaluationOptionEntity),
      };
    } catch {
      return errorResult("Error de conexion. Intenta mas tarde.");
    }
  },

  async exportEvaluationReport(input: ExportEvaluationReportInput): Promise<ApiResult<ExportedReportFile>> {
    const parsedInput = parseWithSchema(ExportEvaluationReportSchema, input);
    if (!parsedInput.ok) {
      return parsedInput;
    }

    try {
      const response = await fetch("/api/reports/export/evaluation", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(parsedInput.data),
      });

      if (!response.ok) {
        return serverErrorResult(response, fallbackExportMessage);
      }

      const blob = await response.blob();
      const disposition = response.headers.get("content-disposition") || "";
      const fileNameMatch = disposition.match(/filename="([^"]+)"/);
      const fileName = fileNameMatch?.[1] ?? "reporte_evaluaciones.xlsx";
      const contentType =
        response.headers.get("content-type") ||
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

      return {
        ok: true,
        data: {
          fileName,
          contentType,
          blob,
        },
      };
    } catch {
      return errorResult("Error de conexion. Intenta mas tarde.");
    }
  },

  async exportAttendanceReport(input: ExportAttendanceReportInput): Promise<ApiResult<ExportedReportFile>> {
    const parsedInput = parseWithSchema(ExportAttendanceReportSchema, input);
    if (!parsedInput.ok) {
      return parsedInput;
    }

    try {
      const response = await fetch("/api/reports/export/attendance", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(parsedInput.data),
      });

      if (!response.ok) {
        return serverErrorResult(response, fallbackAttendanceExportMessage);
      }

      const blob = await response.blob();
      const disposition = response.headers.get("content-disposition") || "";
      const fileNameMatch = disposition.match(/filename="([^"]+)"/);
      const fileName = fileNameMatch?.[1] ?? "reporte_asistencia.xlsx";
      const contentType =
        response.headers.get("content-type") ||
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

      return {
        ok: true,
        data: {
          fileName,
          contentType,
          blob,
        },
      };
    } catch {
      return errorResult("Error de conexion. Intenta mas tarde.");
    }
  },
};
