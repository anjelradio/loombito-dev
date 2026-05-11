"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { XCircle } from "lucide-react";

import AppAlertModal from "@/features/shared/components/modals/AppAlertModal";
import { appToast } from "@/features/shared/components/toast/toast";
import PrimaryActionButton from "@/features/shared/components/ui/PrimaryActionButton";
import { cancelSubscription } from "@/features/subscriptions/presentation/actions/cancel-subscription-action";

type CancelSubscriptionButtonProps = {
  schoolId: string;
  planName: string;
};

export default function CancelSubscriptionButton({
  schoolId,
  planName,
}: CancelSubscriptionButtonProps) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [isPending, startTransition] = useTransition();

  const handleCancel = () => {
    startTransition(async () => {
      const response = await cancelSubscription(schoolId);
      if (!response.ok) {
        appToast.error(response.errors[0] ?? "No se pudo cancelar la renovacion.");
        return;
      }

      appToast.success("Renovacion cancelada correctamente");
      setOpen(false);
      router.refresh();
    });
  };

  return (
    <>
      <PrimaryActionButton
        className="h-10 rounded-lg bg-[#b42318] px-4 text-sm hover:bg-[#912018]"
        disabled={isPending}
        onClick={() => setOpen(true)}
      >
        <XCircle className="mr-2 h-4 w-4" />
        Cancelar renovacion
      </PrimaryActionButton>

      <AppAlertModal
        open={open}
        onOpenChange={setOpen}
        title="Cancelar renovacion"
        description={`Se solicitara a Stripe cancelar la renovacion del plan ${planName} al finalizar el periodo actual.`}
        actionText={isPending ? "Cancelando..." : "Cancelar renovacion"}
        cancelText="Volver"
        onAction={handleCancel}
        actionDisabled={isPending}
      />
    </>
  );
}
