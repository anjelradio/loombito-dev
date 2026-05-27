"use server";

import { communicationRepository } from "@/features/communications/data/repositories";

export async function createStudentCommunication(schoolId: string, studentId: string, data: unknown) {
  return communicationRepository.createStudentCommunication(schoolId, studentId, data);
}
