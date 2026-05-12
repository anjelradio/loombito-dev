import { apiRequestJson, apiRequestStatus } from "@/features/shared/infrastructure/api/api-client";
import type { ApiActionResult, ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import type { SchoolBackup } from "@/features/system/domain/entities/school-backup";

import { toCreatedSchoolBackupEntity } from "../mappers/school-backup-response.mapper";
import { CreateSchoolBackupResponseSchema } from "../schemas/school-backup-response.schema";

const basePath = "/api/system/backups/schools";

export const schoolBackupBrowserApi = {
  createSchoolBackup(schoolId: string): Promise<ApiResult<SchoolBackup>> {
    return apiRequestJson({
      url: `${basePath}/${schoolId}`,
      method: "POST",
      fallbackMessage: "No se pudo crear la copia de seguridad.",
      responseSchema: CreateSchoolBackupResponseSchema,
      mapData: toCreatedSchoolBackupEntity,
    });
  },

  restoreSchoolBackup(schoolId: string, backupId: string): Promise<ApiActionResult> {
    return apiRequestStatus({
      url: `${basePath}/${schoolId}/${backupId}/restore`,
      method: "POST",
      body: { confirm_text: "RESTAURAR" },
      fallbackMessage: "No se pudo restaurar la copia de seguridad.",
    });
  },

  deleteSchoolBackup(schoolId: string, backupId: string): Promise<ApiActionResult> {
    return apiRequestStatus({
      url: `${basePath}/${schoolId}/${backupId}`,
      method: "DELETE",
      fallbackMessage: "No se pudo eliminar la copia de seguridad.",
    });
  },
};
