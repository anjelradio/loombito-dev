import { intelligenceApi } from "../api/intelligence-api";

export const intelligenceRepository = {
  getStudentClusters(schoolId: string, assignmentId: string, termId: string) {
    return intelligenceApi.getStudentClusters(schoolId, assignmentId, termId);
  },

  recalculateStudentClusters(schoolId: string, assignmentId: string, termId: string) {
    return intelligenceApi.recalculateStudentClusters(schoolId, assignmentId, termId);
  },
};
