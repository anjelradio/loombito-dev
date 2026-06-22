import { studentPaymentApi } from "../api/student-payment-api";

// Repositorio que wrappea el API de pagos del estudiante
export const studentPaymentRepository = {
  // Obtiene el historial de pagos delegando al API
  getStudentPayments: async (schoolId: string, studentId: string) => {
    return studentPaymentApi.getStudentPayments(schoolId, studentId);
  },
};
