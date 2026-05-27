"use server";

import { communicationRepository } from "@/features/communications/data/repositories";

export async function deleteStudentCommunication(schoolId: string, communicationId: string) {
  return communicationRepository.deleteStudentCommunication(schoolId, communicationId);
}
