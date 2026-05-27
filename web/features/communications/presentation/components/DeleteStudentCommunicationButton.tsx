"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";

import type { StudentCommunication } from "@/features/communications/domain/entities/student-communication";
import { deleteStudentCommunication } from "@/features/communications/presentation/actions/delete-student-communication-action";
import AppAlertModal from "@/features/shared/components/modals/AppAlertModal";
import { appToast } from "@/features/shared/components/toast/toast";

type DeleteStudentCommunicationButtonProps = {
  schoolId: string;
  communication: StudentCommunication;
};

export default function DeleteStudentCommunicationButton({
  schoolId,
  communication,
}: DeleteStudentCommunicationButtonProps) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [isPending, startTransition] = useTransition();

  const handleDelete = () => {
    startTransition(async () => {
      const result = await deleteStudentCommunication(schoolId, communication.id);
      if (!result.ok) {
        appToast.error(result.errors[0] ?? "No se pudo eliminar el comunicado");
        return;
      }

      appToast.success("Comunicado eliminado");
      setOpen(false);
      router.refresh();
    });
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="h-9 rounded-lg border border-[#f2c8c8] bg-white px-3 text-sm font-semibold text-[#b84f4f] hover:bg-[#fff5f5]"
      >
        Eliminar
      </button>
      <AppAlertModal
        open={open}
        onOpenChange={setOpen}
        title="Eliminar comunicado"
        description={`¿Estas seguro de eliminar \"${communication.title}\"?`}
        actionText={isPending ? "Eliminando..." : "Eliminar"}
        cancelText="Cancelar"
        onAction={handleDelete}
        actionDisabled={isPending}
      />
    </>
  );
}
