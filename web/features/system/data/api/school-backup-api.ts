import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { apiRequestJson, apiRequestStatus } from "@/features/shared/infrastructure/api/api-client";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiActionResult, ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import type { SchoolBackup } from "@/features/system/domain/entities/school-backup";

import {
  toCreatedSchoolBackupEntity,
  toSchoolBackupEntity,
} from "../mappers/school-backup-response.mapper";
import {
  CreateSchoolBackupResponseSchema,
  SchoolBackupListResponseSchema,
} from "../schemas/school-backup-response.schema";

const basePath = `${env.API_URL}/system/backups/schools`;

export const schoolBackupApi = {
  async getSchoolBackups(schoolId: string): Promise<ApiResult<SchoolBackup[]>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${basePath}/${schoolId}`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudo listar copias de seguridad.",
      responseSchema: SchoolBackupListResponseSchema,
      mapData: (dto) => dto.map(toSchoolBackupEntity),
    });
  },

  async createSchoolBackup(schoolId: string): Promise<ApiResult<SchoolBackup>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${basePath}/${schoolId}`,
      method: "POST",
      token,
      fallbackMessage: "No se pudo crear la copia de seguridad.",
      responseSchema: CreateSchoolBackupResponseSchema,
      mapData: toCreatedSchoolBackupEntity,
    });
  },

  async deleteSchoolBackup(schoolId: string, backupId: string): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestStatus({
      url: `${basePath}/${schoolId}/${backupId}`,
      method: "DELETE",
      token,
      fallbackMessage: "No se pudo eliminar la copia de seguridad.",
    });
  },
};
