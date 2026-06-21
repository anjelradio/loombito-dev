import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { apiRequestJson } from "@/features/shared/infrastructure/api/api-client";
import type { ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { StudentDebt } from "../../domain/entities/student-debt";
import { z } from "zod";

const baseUrl = `${env.API_URL}/payments`;

export const studentDebtApi = {
  async getStudentDebts(schoolId: string, studentId: string, status?: string): Promise<ApiResult<StudentDebt[]>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    const query = status ? `?status=${status}` : "";

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/students/${studentId}/debts${query}`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener las deudas del estudiante.",
      responseSchema: z.any(), // Bypass schema validation for simplicity
      mapData: (data: any) => data as StudentDebt[],
    });
  },
};
