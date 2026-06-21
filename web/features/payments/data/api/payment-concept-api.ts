import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";
import {
  apiRequestJson,
  apiRequestStatus,
} from "@/features/shared/infrastructure/api/api-client";
import type {
  ApiActionResult,
  ApiResult,
} from "@/features/shared/infrastructure/types/api-resource";
import { errorResult } from "@/features/shared/infrastructure/errors/api-error-result";
import { parseWithSchema } from "@/features/shared/infrastructure/api/parse-with-schema";
import type { PaymentConcept } from "../../domain/entities/payment-concept";
import { PaymentConceptCreateSchema, PaymentConceptUpdateSchema } from "../schemas/payment-concept-schema";
import { z } from "zod";

const baseUrl = `${env.API_URL}/payments`;

export const paymentConceptApi = {
  async getPaymentConceptsBySchool(schoolId: string): Promise<ApiResult<PaymentConcept[]>> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestJson({
      url: `${baseUrl}/schools/${schoolId}/concepts`,
      method: "GET",
      token,
      cache: "no-store",
      fallbackMessage: "No se pudieron obtener los conceptos de pago.",
      responseSchema: z.any(), // bypass schema validation for now
      mapData: (data: any) => data as PaymentConcept[],
    });
  },

  async createPaymentConcept(schoolId: string, data: unknown): Promise<ApiActionResult> {
    const input = parseWithSchema(PaymentConceptCreateSchema, data);
    if (!input.ok) {
      return input;
    }

    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/concepts`,
      method: "POST",
      token,
      body: input.data,
      fallbackMessage: "No se pudo crear el concepto de pago.",
    });
  },

  async updatePaymentConcept(
    schoolId: string,
    conceptId: string,
    data: unknown,
  ): Promise<ApiActionResult> {
    const input = parseWithSchema(PaymentConceptUpdateSchema, data);
    if (!input.ok) {
      return input;
    }

    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/concepts/${conceptId}`,
      method: "PUT",
      token,
      body: input.data,
      fallbackMessage: "No se pudo actualizar el concepto de pago.",
    });
  },

  async deletePaymentConcept(schoolId: string, conceptId: string): Promise<ApiActionResult> {
    const token = await getToken();
    if (!token) {
      return errorResult("No autorizado");
    }

    return apiRequestStatus({
      url: `${baseUrl}/schools/${schoolId}/concepts/${conceptId}`,
      method: "DELETE",
      token,
      fallbackMessage: "No se pudo eliminar el concepto de pago.",
    });
  },
};
