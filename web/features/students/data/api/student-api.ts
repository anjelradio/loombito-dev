import {
  apiRequestJson,
  apiRequestStatus,
} from "@/features/shared/infrastructure/api/api-client";
import type {
  ApiActionResult,
  ApiResult,
} from "@/features/shared/infrastructure/types/api-resource";
import { parseWithSchema } from "@/features/shared/infrastructure/api/parse-with-schema";
import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type { Student, StudentList } from "../../domain/entities/student";
import type {
  EvaluationFinalizeSummary,
  StudentGradebookRow,
} from "../../domain/entities/student-gradebook";

import {
  serverErrorResult,
} from "@/features/shared/infrastructure/errors/api-error-result";
import {
  toEvaluationFinalizeSummaryEntity,
  toStudentInviteExportRequestDto,
  toStudentCreateRequestDto,
  toStudentEntity,
  toStudentGradeUpsertRequestDto,
  toStudentGradebookRowEntity,
  toStudentListEntity,
  toStudentUpdateRequestDto,
} from "../mappers";
import {
  EvaluationFinalizeSummaryResponseSchema,
  StudentCreateSchema,
  StudentGradeUpsertSchema,
  StudentGradebookRowResponseSchema,
  StudentListResponseSchema,
  StudentResponseSchema,
  StudentInviteExportSchema,
  StudentUpdateSchema,
} from "../schemas";

const baseUrl = `${env.API_URL}/students`;

export const studentApi = {
  async getStudentsByEvaluation(schoolId: string, evaluationId: string): Promise<ApiResult<Student[]>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/evaluations/${evaluationId}/students`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los estudiantes de la evaluacion.",
      responseSchema: StudentResponseSchema.array(),
      mapData: (dtoList) => dtoList.map(toStudentEntity),
    });
  },

  async getGradebookByEvaluation(
    schoolId: string,
    evaluationId: string,
  ): Promise<ApiResult<StudentGradebookRow[]>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/evaluations/${evaluationId}/gradebook`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudo obtener el gradebook.",
      responseSchema: StudentGradebookRowResponseSchema.array(),
      mapData: (dtoList) => dtoList.map(toStudentGradebookRowEntity),
    });
  },

  async upsertGradeByEvaluationStudent(
    schoolId: string,
    evaluationId: string,
    studentId: string,
    data: unknown,
  ): Promise<ApiActionResult> {
    const input = parseWithSchema(StudentGradeUpsertSchema, data);
    if (!input.ok) {
      return input;
    }

    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/evaluations/${evaluationId}/students/${studentId}/grade`,
      method: "PUT",
      token,
      body: toStudentGradeUpsertRequestDto(input.data),
      fallbackMessage: "No se pudo guardar la calificacion.",
    });
  },

  async finalizeEvaluation(schoolId: string, evaluationId: string): Promise<ApiResult<EvaluationFinalizeSummary>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/evaluations/${evaluationId}/finalize`,
      method: "POST",
      token,
      fallbackMessage: "No se pudo finalizar la evaluacion.",
      responseSchema: EvaluationFinalizeSummaryResponseSchema,
      mapData: toEvaluationFinalizeSummaryEntity,
    });
  },

  async getStudentsByCourse(
    schoolId: string,
    courseId: string,
    page = 1,
    perPage = 8,
    search?: string,
  ): Promise<ApiResult<StudentList>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    const params = new URLSearchParams();
    params.set("page", String(page));
    params.set("per_page", String(perPage));
    if (search && search.trim()) {
      params.set("search", search.trim());
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/courses/${courseId}?${params.toString()}`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los estudiantes del curso.",
      responseSchema: StudentListResponseSchema,
      mapData: toStudentListEntity,
    });
  },

  async getStudentById(
    schoolId: string,
    studentId: string,
  ): Promise<ApiResult<Student>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/students/${studentId}`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudo obtener el estudiante.",
      responseSchema: StudentResponseSchema,
      mapData: toStudentEntity,
    });
  },

  async createStudentInCourse(
    schoolId: string,
    courseId: string,
    data: unknown,
  ): Promise<ApiActionResult> {
    const input = parseWithSchema(StudentCreateSchema, data);
    if (!input.ok) {
      return input;
    }

    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/courses/${courseId}`,
      method: "POST",
      token,
      body: toStudentCreateRequestDto(input.data),
      fallbackMessage: "No se pudo crear el estudiante.",
    });
  },

  async updateStudent(schoolId: string, studentId: string, data: unknown): Promise<ApiActionResult> {
    const input = parseWithSchema(StudentUpdateSchema, data);
    if (!input.ok) {
      return input;
    }

    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/students/${studentId}`,
      method: "PUT",
      token,
      body: toStudentUpdateRequestDto(input.data),
      fallbackMessage: "No se pudo actualizar el estudiante.",
    });
  },

  async unlinkStudentFromCourse(
    schoolId: string,
    courseId: string,
    studentId: string,
  ): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/courses/${courseId}/students/${studentId}`,
      method: "DELETE",
      token,
      fallbackMessage: "No se pudo desvincular el estudiante del curso.",
    });
  },

  async exportStudentInvitesByCourse(
    schoolId: string,
    courseId: string,
    data: unknown,
  ): Promise<ApiResult<{ fileName: string; contentType: string; base64: string }>> {
    const input = parseWithSchema(StudentInviteExportSchema, data);
    if (!input.ok) {
      return input;
    }

    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    try {
      const response = await fetch(`${baseUrl}/schools/${schoolId}/courses/${courseId}/invites/export`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(toStudentInviteExportRequestDto(input.data)),
      });

      if (!response.ok) {
        return serverErrorResult(response, "No se pudieron generar los codigos de vinculacion.");
      }

      const fileBuffer = await response.arrayBuffer();
      const disposition = response.headers.get("content-disposition") || "";
      const fileNameMatch = disposition.match(/filename="([^"]+)"/);
      const fileName = fileNameMatch?.[1] ?? "codigos_vinculacion_estudiantes.xlsx";
      const contentType =
        response.headers.get("content-type") ||
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

      return {
        ok: true,
        data: {
          fileName,
          contentType,
          base64: Buffer.from(fileBuffer).toString("base64"),
        },
      };
    } catch {
      return errorResult("Error de conexion. Intenta mas tarde.");
    }
  },
};
