"use server";

import { studentRepository } from "@/features/students/data/repositories/student.repository";

export async function getCourseStudentsAction(
  schoolId: string,
  courseId: string,
  page = 1,
  perPage = 50
) {
  return studentRepository.getStudentsByCourse(schoolId, courseId, page, perPage);
}

import { boletinesApi } from "@/features/reports/data/api/boletines-api";

export async function exportBoletinAction(
  schoolId: string,
  courseId: string,
  studentId: string,
) {
  const result = await boletinesApi.exportBoletinPdf(schoolId, courseId, studentId);
  
  if (!result.ok) {
    return { ok: false, error: result.error };
  }

  const arrayBuffer = await result.data.blob.arrayBuffer();
  const base64 = Buffer.from(arrayBuffer).toString('base64');

  return {
    ok: true,
    data: {
      fileName: result.data.fileName,
      contentType: result.data.contentType,
      base64,
    }
  };
}
