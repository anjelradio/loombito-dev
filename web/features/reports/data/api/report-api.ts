import { apiRequestJson } from "@/features/shared/infrastructure/api/api-client";
import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiResult } from "@/features/shared/infrastructure/types/api-resource";

import { toReportRunEntity } from "../mappers/report.mapper";
import { ReportRunResponseSchema } from "../schemas/report-response.schema";
import type { ReportRun, ReportType } from "../../domain/entities/report";

const baseUrl = `${env.API_URL}/reports`;

export const reportApi = {
  async getRunsBySchool(schoolId: string, reportType?: ReportType): Promise<ApiResult<ReportRun[]>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    const query = reportType ? `?report_type=${reportType}` : "";
    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/runs${query}`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los reportes.",
      responseSchema: ReportRunResponseSchema.array(),
      mapData: (dtoList) => dtoList.map(toReportRunEntity),
    });
  },
};
