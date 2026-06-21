"use client";

import { useState, useTransition } from "react";
import { Trash2 } from "lucide-react";

import { deletePaymentConceptAction } from "@/features/payments/presentation/actions/concepts/payment-concept-actions";
import AppAlertModal from "@/features/shared/components/modals/AppAlertModal";
import { appToast } from "@/features/shared/components/toast/toast";

type PaymentConceptDeleteButtonProps = {
  schoolId: string;
  conceptId: string;
  conceptName: string;
};

export default function PaymentConceptDeleteButton({
  schoolId,
  conceptId,
  conceptName,
}: PaymentConceptDeleteButtonProps) {
  const [open, setOpen] = useState(false);
  const [isPending, startTransition] = useTransition();

  const handleDelete = () => {
    startTransition(async () => {
      const result = await deletePaymentConceptAction(schoolId, conceptId);
      if (result.ok) {
        appToast.success("Concepto eliminado correctamente");
      } else {
        appToast.error(result.errors[0] || "No se pudo eliminar el concepto");
      }
      setOpen(false);
    });
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[#f2c8c8] bg-white text-[#b84f4f] transition-colors hover:bg-[#fff5f5]"
        aria-label="Eliminar concepto"
      >
        <Trash2 className="h-4 w-4" />
      </button>

      <AppAlertModal
        open={open}
        onOpenChange={setOpen}
        title="Eliminar concepto de pago"
        description={`¿Estás seguro de que deseas eliminar "${conceptName}"? Esta acción no se puede deshacer y no se aplicará a nuevas deudas.`}
        actionText={isPending ? "Eliminando..." : "Eliminar"}
        cancelText="Cancelar"
        onAction={handleDelete}
        actionDisabled={isPending}
      />
    </>
  );
}
