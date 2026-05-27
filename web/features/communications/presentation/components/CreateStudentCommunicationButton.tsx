"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import AppModal from "@/features/shared/components/modals/AppModal";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import PrimaryActionButton from "@/features/shared/components/ui/PrimaryActionButton";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import { appToast } from "@/features/shared/components/toast/toast";
import { submitWithSchema } from "@/features/shared/infrastructure/forms/submit-with-schema";
import { StudentCommunicationCreateSchema } from "@/features/communications/data/schemas";
import { createStudentCommunication } from "@/features/communications/presentation/actions/create-student-communication-action";

import StudentCommunicationForm from "./StudentCommunicationForm";

type CreateStudentCommunicationButtonProps = {
  schoolId: string;
  studentId: string;
};

export default function CreateStudentCommunicationButton({
  schoolId,
  studentId,
}: CreateStudentCommunicationButtonProps) {
  const router = useRouter();
  const [open, setOpen] = useState(false);

  const handleSubmit = async (formData: FormData) => {
    await submitWithSchema({
      schema: StudentCommunicationCreateSchema,
      payload: {
        title: formData.get("title"),
        body: formData.get("body"),
      },
      action: (data) => createStudentCommunication(schoolId, studentId, data),
      onSuccess: () => {
        appToast.success("Comunicado creado correctamente");
        setOpen(false);
        router.refresh();
      },
    });
  };

  return (
    <>
      <PrimaryActionButton className="h-10 rounded-lg px-4 text-sm" onClick={() => setOpen(true)}>
        Crear comunicado
      </PrimaryActionButton>

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Nuevo comunicado"
        description="Completa titulo y descripcion para registrar un comunicado del estudiante."
      >
        <form action={handleSubmit} className="space-y-6">
          <StudentCommunicationForm />
          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <ModalSecondaryButton onClick={() => setOpen(false)}>Cancelar</ModalSecondaryButton>
            <SubmitButton pendingText="Guardando..." className="h-12 bg-[#1E3A5F] px-5 font-semibold text-white">
              Guardar comunicado
            </SubmitButton>
          </div>
        </form>
      </AppModal>
    </>
  );
}
