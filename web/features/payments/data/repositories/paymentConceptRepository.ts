import { paymentConceptApi } from "../api/payment-concept-api";

export const paymentConceptRepository = {
  getPaymentConceptsBySchool(schoolId: string) {
    return paymentConceptApi.getPaymentConceptsBySchool(schoolId);
  },

  createPaymentConcept(schoolId: string, data: unknown) {
    return paymentConceptApi.createPaymentConcept(schoolId, data);
  },

  updatePaymentConcept(schoolId: string, conceptId: string, data: unknown) {
    return paymentConceptApi.updatePaymentConcept(schoolId, conceptId, data);
  },

  deletePaymentConcept(schoolId: string, conceptId: string) {
    return paymentConceptApi.deletePaymentConcept(schoolId, conceptId);
  },
};
