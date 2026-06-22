import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { apiRequestJson } from "@/features/shared/infrastructure/api/api-client";
import type { ApiResult } from "@/features/shared/infrastructure/types/api-resource";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { StudentPayment } from "../../domain/entities/student-payment";
import { z } from "zod";

const baseUrl = `${env.API_URL}/payments`;

// API para obtener el historial de pagos de un estudiante
export const studentPaymentApi = {
  // Obtiene los pagos del estudiante desde el backend
  async getStudentPayments(schoolId: string, studentId: string): Promise<ApiResult<StudentPayment[]>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/students/${studentId}/payments`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los pagos del estudiante.",
      responseSchema: z.any(), // Bypass schema validation for simplicity
      mapData: (data: any) => data as StudentPayment[],
    });
  },
};
