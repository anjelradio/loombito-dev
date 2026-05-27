import { studentApi } from "../api/student-api";

export const studentRepository = {
  getStudentsByEvaluation(schoolId: string, evaluationId: string) {
    return studentApi.getStudentsByEvaluation(schoolId, evaluationId);
  },

  getGradebookByEvaluation(schoolId: string, evaluationId: string) {
    return studentApi.getGradebookByEvaluation(schoolId, evaluationId);
  },

  upsertGradeByEvaluationStudent(
    schoolId: string,
    evaluationId: string,
    studentId: string,
    data: unknown,
  ) {
    return studentApi.upsertGradeByEvaluationStudent(schoolId, evaluationId, studentId, data);
  },

  finalizeEvaluation(schoolId: string, evaluationId: string) {
    return studentApi.finalizeEvaluation(schoolId, evaluationId);
  },

  getStudentsByCourse(
    schoolId: string,
    courseId: string,
    page?: number,
    perPage?: number,
    search?: string,
  ) {
    return studentApi.getStudentsByCourse(schoolId, courseId, page, perPage, search);
  },

  createStudentInCourse(schoolId: string, courseId: string, data: unknown) {
    return studentApi.createStudentInCourse(schoolId, courseId, data);
  },

  updateStudent(schoolId: string, studentId: string, data: unknown) {
    return studentApi.updateStudent(schoolId, studentId, data);
  },

  unlinkStudentFromCourse(schoolId: string, courseId: string, studentId: string) {
    return studentApi.unlinkStudentFromCourse(schoolId, courseId, studentId);
  },

  exportStudentInvitesByCourse(schoolId: string, courseId: string, data: unknown) {
    return studentApi.exportStudentInvitesByCourse(schoolId, courseId, data);
  },
};
