import { apiRequestFile } from "@/features/shared/infrastructure/api/api-client";
import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { ApiFileResult } from "@/features/shared/infrastructure/types/api-resource";

const baseUrl = `${env.API_URL}/reports`;

export const boletinesApi = {
  async exportBoletinPdf(
    schoolId: string,
    courseId: string,
    studentId: string,
    summary?: string,
  ): Promise<ApiFileResult> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestFile({
      url: `${baseUrl}/schools/${schoolId}/export/boletin`,
      method: "POST",
      token,
      body: {
        course_id: courseId,
        student_id: studentId,
        format: "pdf",
        summary: summary || null,
      },
      fallbackMessage: "No se pudo generar el boletín.",
      defaultFileName: "boletin.pdf",
      defaultContentType: "application/pdf",
    });
  },
};
