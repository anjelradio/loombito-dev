"use client";

import { useState } from "react";
import { Pencil } from "lucide-react";

import AppModal from "@/features/shared/components/modals/AppModal";
import PaymentConceptForm from "./PaymentConceptForm";
import type { PaymentConcept } from "@/features/payments/domain/entities/payment-concept";

type PaymentConceptEditButtonProps = {
  schoolId: string;
  concept: PaymentConcept;
};

export default function PaymentConceptEditButton({ schoolId, concept }: PaymentConceptEditButtonProps) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[#c7dbf1] bg-white text-[#345b86] transition-colors hover:bg-[#f3f8ff]"
        aria-label="Editar concepto"
      >
        <Pencil className="h-4 w-4" />
      </button>

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Editar concepto de pago"
        description={`Modifica los datos del concepto "${concept.name}".`}
        size="lg"
      >
        <PaymentConceptForm
          schoolId={schoolId}
          initialData={concept}
          onClose={() => setOpen(false)}
        />
      </AppModal>
    </>
  );
}
