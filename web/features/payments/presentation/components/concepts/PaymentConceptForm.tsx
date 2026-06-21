"use client";

import { useRef, useState } from "react";

import { PaymentConceptCreateSchema, PaymentConceptUpdateSchema } from "@/features/payments/data/schemas/payment-concept-schema";
import { createPaymentConceptAction, updatePaymentConceptAction } from "@/features/payments/presentation/actions/concepts/payment-concept-actions";
import { FormTextField } from "@/features/shared/components/forms/FormTextField";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import { appToast } from "@/features/shared/components/toast/toast";
import { submitWithSchema } from "@/features/shared/infrastructure/forms/submit-with-schema";
import type { PaymentConcept } from "@/features/payments/domain/entities/payment-concept";

type PaymentConceptFormProps = {
  schoolId: string;
  initialData?: PaymentConcept;
  onClose: () => void;
};

export default function PaymentConceptForm({ schoolId, initialData, onClose }: PaymentConceptFormProps) {
  const formRef = useRef<HTMLFormElement>(null);
  const isEditing = !!initialData;
  const [isRecurring, setIsRecurring] = useState(initialData?.is_recurring ?? true);

  const handleSubmit = async (formData: FormData) => {
    const rawData = {
      name: formData.get("name"),
      amount: formData.get("amount"),
      is_recurring: isRecurring,
    };

    if (isEditing) {
      await submitWithSchema({
        schema: PaymentConceptUpdateSchema,
        payload: rawData,
        action: (data) => updatePaymentConceptAction(schoolId, initialData.id, data),
        onSuccess: () => {
          appToast.success("Concepto actualizado correctamente");
          onClose();
        },
      });
    } else {
      await submitWithSchema({
        schema: PaymentConceptCreateSchema,
        payload: rawData,
        action: (data) => createPaymentConceptAction(schoolId, data as any),
        onSuccess: () => {
          appToast.success("Concepto registrado correctamente");
          onClose();
        },
      });
    }
  };

  return (
    <form ref={formRef} action={handleSubmit} className="space-y-4">
      <FormTextField
        id="name"
        name="name"
        label="Nombre del concepto"
        defaultValue={initialData?.name}
        placeholder="Ej: Mensualidad"
        required
      />

      <FormTextField
        id="amount"
        name="amount"
        label="Monto (Bs.)"
        type="number"
        step="0.01"
        defaultValue={initialData?.amount?.toString()}
        placeholder="Ej: 400"
        required
      />

      <div className="flex items-center gap-2 pt-2 pb-2">
        <input
          type="checkbox"
          id="is_recurring"
          name="is_recurring"
          checked={isRecurring}
          onChange={(e) => setIsRecurring(e.target.checked)}
          className="h-4 w-4 rounded border-gray-300 text-[#1E3A5F] focus:ring-[#1E3A5F]"
        />
        <label htmlFor="is_recurring" className="text-sm font-medium text-gray-700">
          Es recurrente (se generará cada 1ro del mes a las 00:00)
        </label>
      </div>

      <div className="flex items-center justify-end gap-3 pt-4 border-t">
        <button
          type="button"
          onClick={onClose}
          className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
        >
          Cancelar
        </button>
        <SubmitButton
          pendingText={isEditing ? "Actualizando..." : "Registrando..."}
          className="bg-[#1E3A5F] px-4 py-2 text-sm font-medium text-white hover:bg-[#152B47]"
        >
          {isEditing ? "Guardar cambios" : "Registrar"}
        </SubmitButton>
      </div>
    </form>
  );
}
