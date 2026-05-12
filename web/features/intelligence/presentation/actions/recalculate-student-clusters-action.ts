"use server";

import { intelligenceRepository } from "@/features/intelligence/data/repositories/intelligence.repository";

export async function recalculateStudentClusters(
  schoolId: string,
  assignmentId: string,
  termId: string,
) {
  return intelligenceRepository.recalculateStudentClusters(schoolId, assignmentId, termId);
}
