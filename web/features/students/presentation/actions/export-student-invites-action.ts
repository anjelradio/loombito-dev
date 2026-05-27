"use server";

import { studentRepository } from "@/features/students/data/repositories";

export async function exportStudentInvitesByCourseAction(
  schoolId: string,
  courseId: string,
  data: unknown,
) {
  return studentRepository.exportStudentInvitesByCourse(schoolId, courseId, data);
}
