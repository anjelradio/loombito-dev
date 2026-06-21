import { studentDebtApi } from "../api/student-debt-api";

export const studentDebtRepository = {
  getStudentDebts(schoolId: string, studentId: string, status?: string) {
    return studentDebtApi.getStudentDebts(schoolId, studentId, status);
  },
};
