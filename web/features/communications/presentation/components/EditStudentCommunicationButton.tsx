"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import type { StudentCommunication } from "@/features/communications/domain/entities/student-communication";
import { StudentCommunicationUpdateSchema } from "@/features/communications/data/schemas";
import { updateStudentCommunication } from "@/features/communications/presentation/actions/update-student-communication-action";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import AppModal from "@/features/shared/components/modals/AppModal";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import { appToast } from "@/features/shared/components/toast/toast";
import { submitWithSchema } from "@/features/shared/infrastructure/forms/submit-with-schema";

import StudentCommunicationForm from "./StudentCommunicationForm";

type EditStudentCommunicationButtonProps = {
  schoolId: string;
  communication: StudentCommunication;
};

export default function EditStudentCommunicationButton({
  schoolId,
  communication,
}: EditStudentCommunicationButtonProps) {
  const router = useRouter();
  const [open, setOpen] = useState(false);

  const handleSubmit = async (formData: FormData) => {
    await submitWithSchema({
      schema: StudentCommunicationUpdateSchema,
      payload: {
        title: formData.get("title"),
        body: formData.get("body"),
      },
      action: (data) => updateStudentCommunication(schoolId, communication.id, data),
      onSuccess: () => {
        appToast.success("Comunicado actualizado");
        setOpen(false);
        router.refresh();
      },
    });
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="h-9 rounded-lg border border-[#c6d7ea] bg-white px-3 text-sm font-semibold text-[#315a85] hover:bg-[#f5f9ff]"
      >
        Editar
      </button>
      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Editar comunicado"
        description="Actualiza el contenido del comunicado del estudiante."
      >
        <form action={handleSubmit} className="space-y-6">
          <StudentCommunicationForm communication={communication} />
          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <ModalSecondaryButton onClick={() => setOpen(false)}>Cancelar</ModalSecondaryButton>
            <SubmitButton
              pendingText="Guardando..."
              className="h-12 bg-[#1E3A5F] px-5 font-semibold text-white hover:bg-[#152B47]"
            >
              Guardar cambios
            </SubmitButton>
          </div>
        </form>
      </AppModal>
    </>
  );
}
