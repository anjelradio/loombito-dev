import { studentPaymentApi } from "../api/student-payment-api";

export const studentPaymentRepository = {
  getStudentPayments: async (schoolId: string, studentId: string) => {
    return studentPaymentApi.getStudentPayments(schoolId, studentId);
  },
};
