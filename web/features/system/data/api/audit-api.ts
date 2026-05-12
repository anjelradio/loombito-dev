import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { apiRequestJson } from "@/features/shared/infrastructure/api/api-client";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiActionResult, ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import type { AuditLogList } from "@/features/system/domain/entities/audit-log";

import {
  AuditLogListResponseSchema,
  RequestAuditAccessResponseSchema,
  VerifyAuditAccessResponseSchema,
} from "../schemas/audit-log-response.schema";
import { toAuditLogListEntity } from "../mappers/audit-log-response.mapper";

const baseUrl = `${env.API_URL}/system/audit`;

export const auditApi = {
  async requestAccessKey(): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    const response = await apiRequestJson({
      url: `${baseUrl}/access/request`,
      method: "POST",
      token,
      fallbackMessage: "No se pudo enviar la llave de acceso.",
      responseSchema: RequestAuditAccessResponseSchema,
      mapData: (dto) => dto,
    });

    if (!response.ok) return response;
    return { ok: true };
  },

  async verifyAccessKey(accessKey: string): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    const response = await apiRequestJson({
      url: `${baseUrl}/access/verify`,
      method: "POST",
      token,
      body: { access_key: accessKey },
      fallbackMessage: "No se pudo verificar la llave de acceso.",
      responseSchema: VerifyAuditAccessResponseSchema,
      mapData: (dto) => dto,
    });

    if (!response.ok) return response;
    return { ok: true };
  },

  async getSchoolAuditLogs(
    schoolId: string,
    page = 1,
    perPage = 8,
  ): Promise<ApiResult<AuditLogList>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    const params = new URLSearchParams();
    params.set("page", String(page));
    params.set("per_page", String(perPage));
    params.set("school_id", schoolId);

    return apiRequestJson({
      url: `${baseUrl}/logs?${params.toString()}`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudo obtener la bitacora.",
      responseSchema: AuditLogListResponseSchema,
      mapData: toAuditLogListEntity,
    });
  },
};
