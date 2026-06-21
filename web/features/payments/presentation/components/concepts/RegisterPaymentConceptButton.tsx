"use client";

import { useState } from "react";

import AppModal from "@/features/shared/components/modals/AppModal";
import PrimaryActionButton from "@/features/shared/components/ui/PrimaryActionButton";
import PaymentConceptForm from "./PaymentConceptForm";

type RegisterPaymentConceptButtonProps = {
  schoolId: string;
};

export default function RegisterPaymentConceptButton({ schoolId }: RegisterPaymentConceptButtonProps) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <PrimaryActionButton onClick={() => setOpen(true)}>Registrar concepto</PrimaryActionButton>

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Registrar concepto de pago"
        description="Agrega un nuevo concepto que podrá ser asignado a los estudiantes."
        size="lg"
      >
        <PaymentConceptForm
          schoolId={schoolId}
          onClose={() => setOpen(false)}
        />
      </AppModal>
    </>
  );
}
