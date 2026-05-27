"use server";

import { communicationRepository } from "@/features/communications/data/repositories";

export async function updateStudentCommunication(
  schoolId: string,
  communicationId: string,
  data: unknown,
) {
  return communicationRepository.updateStudentCommunication(schoolId, communicationId, data);
}
