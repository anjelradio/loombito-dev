import { apiRequestJson, apiRequestStatus } from "@/features/shared/infrastructure/api/api-client";
import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiActionResult, ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import type { StudentClusterSnapshot } from "@/features/intelligence/domain/entities/student-cluster";

import { toStudentClusterSnapshotEntity } from "../mappers/student-cluster-response.mapper";
import { StudentClusterSnapshotResponseSchema } from "../schemas/student-cluster-response.schema";

const baseUrl = `${env.API_URL}/intelligence`;

export const intelligenceApi = {
  async getStudentClusters(
    schoolId: string,
    assignmentId: string,
    termId: string,
  ): Promise<ApiResult<StudentClusterSnapshot>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/assignments/${assignmentId}/terms/${termId}/clusters`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudo obtener la clasificacion.",
      responseSchema: StudentClusterSnapshotResponseSchema,
      mapData: toStudentClusterSnapshotEntity,
    });
  },

  async recalculateStudentClusters(
    schoolId: string,
    assignmentId: string,
    termId: string,
  ): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/assignments/${assignmentId}/terms/${termId}/clusters/recalculate`,
      method: "POST",
      token,
      fallbackMessage: "No se pudo recalcular la clasificacion.",
    });
  },
};
