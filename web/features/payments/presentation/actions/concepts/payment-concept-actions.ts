"use server";

import { revalidatePath } from "next/cache";

import { PaymentConceptCreate, PaymentConceptUpdate } from "../../../domain/entities/payment-concept";
import { paymentConceptRepository } from "../../../data/repositories/paymentConceptRepository";

export async function createPaymentConceptAction(schoolId: string, payload: PaymentConceptCreate) {
  const response = await paymentConceptRepository.createPaymentConcept(schoolId, payload);
  if (response.ok) {
    revalidatePath(`/${schoolId}/pagos/conceptos`);
  }
  return response;
}

export async function updatePaymentConceptAction(
  schoolId: string,
  conceptId: string,
  payload: PaymentConceptUpdate
) {
  const response = await paymentConceptRepository.updatePaymentConcept(schoolId, conceptId, payload);
  if (response.ok) {
    revalidatePath(`/${schoolId}/pagos/conceptos`);
  }
  return response;
}

export async function deletePaymentConceptAction(schoolId: string, conceptId: string) {
  const response = await paymentConceptRepository.deletePaymentConcept(schoolId, conceptId);
  if (response.ok) {
    revalidatePath(`/${schoolId}/pagos/conceptos`);
  }
  return response;
}
