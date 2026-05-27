import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import { apiRequestJson, apiRequestStatus } from "@/features/shared/infrastructure/api/api-client";
import { parseWithSchema } from "@/features/shared/infrastructure/api/parse-with-schema";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import type {
  ApiActionResult,
  ApiResult,
} from "@/features/shared/infrastructure/types/api-resource";
import type {
  StudentCommunication,
  TeacherCommunicationCourse,
  TeacherCommunicationStudent,
} from "@/features/communications/domain/entities/student-communication";
import {
  StudentCommunicationCreateSchema,
  StudentCommunicationResponseSchema,
  StudentCommunicationUpdateSchema,
  TeacherCommunicationCourseResponseSchema,
  TeacherCommunicationStudentResponseSchema,
} from "../schemas";
import {
  toStudentCommunicationEntity,
  toTeacherCommunicationCourseEntity,
  toTeacherCommunicationStudentEntity,
} from "../mappers";

const baseUrl = `${env.API_URL}/communications`;

export const communicationApi = {
  async getTeacherCommunicationCourses(
    schoolId: string,
  ): Promise<ApiResult<TeacherCommunicationCourse[]>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/teacher/schools/${schoolId}/courses`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los cursos para comunicados.",
      responseSchema: TeacherCommunicationCourseResponseSchema.array(),
      mapData: (dtoList) => dtoList.map(toTeacherCommunicationCourseEntity),
    });
  },

  async getTeacherCommunicationStudentsByCourse(
    schoolId: string,
    courseId: string,
  ): Promise<ApiResult<TeacherCommunicationStudent[]>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/teacher/schools/${schoolId}/courses/${courseId}/students`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los estudiantes del curso.",
      responseSchema: TeacherCommunicationStudentResponseSchema.array(),
      mapData: (dtoList) => dtoList.map(toTeacherCommunicationStudentEntity),
    });
  },

  async getStudentCommunications(
    schoolId: string,
    studentId: string,
  ): Promise<ApiResult<StudentCommunication[]>> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/students/${studentId}/communications`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los comunicados del estudiante.",
      responseSchema: StudentCommunicationResponseSchema.array(),
      mapData: (dtoList) => dtoList.map(toStudentCommunicationEntity),
    });
  },

  async createStudentCommunication(
    schoolId: string,
    studentId: string,
    data: unknown,
  ): Promise<ApiActionResult> {
    const input = parseWithSchema(StudentCommunicationCreateSchema, data);
    if (!input.ok) return input;

    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/students/${studentId}/communications`,
      method: "POST",
      token,
      body: input.data,
      fallbackMessage: "No se pudo crear el comunicado.",
    });
  },

  async updateStudentCommunication(
    schoolId: string,
    communicationId: string,
    data: unknown,
  ): Promise<ApiActionResult> {
    const input = parseWithSchema(StudentCommunicationUpdateSchema, data);
    if (!input.ok) return input;

    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/communications/${communicationId}`,
      method: "PUT",
      token,
      body: input.data,
      fallbackMessage: "No se pudo actualizar el comunicado.",
    });
  },

  async deleteStudentCommunication(schoolId: string, communicationId: string): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) return errorResult("No autorizado");

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/communications/${communicationId}`,
      method: "DELETE",
      token,
      fallbackMessage: "No se pudo eliminar el comunicado.",
    });
  },
};
