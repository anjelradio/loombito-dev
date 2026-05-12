import { apiRequestJson } from "@/features/shared/infrastructure/api/api-client";
import type { ApiResult } from "@/features/shared/infrastructure/types/api-resource";
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
};
