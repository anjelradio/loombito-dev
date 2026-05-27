"use client";

import { useState } from "react";

import { FormDateField } from "@/features/shared/components/forms/FormDateField";
import { FormTextField } from "@/features/shared/components/forms/FormTextField";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import AppModal from "@/features/shared/components/modals/AppModal";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import { appToast } from "@/features/shared/components/toast/toast";
import PrimaryActionButton from "@/features/shared/components/ui/PrimaryActionButton";
import { submitWithSchema } from "@/features/shared/infrastructure/forms/submit-with-schema";
import { StudentInviteExportSchema } from "@/features/students/data/schemas";
import { exportStudentInvitesByCourseAction } from "@/features/students/presentation/actions/export-student-invites-action";

type GenerateStudentInviteCodesButtonProps = {
  schoolId: string;
  courseId: string;
};

export default function GenerateStudentInviteCodesButton({
  schoolId,
  courseId,
}: GenerateStudentInviteCodesButtonProps) {
  const [open, setOpen] = useState(false);

  const handleSubmit = async (formData: FormData) => {
    const expiresDate = String(formData.get("expiresDate") || "").trim();
    const maxUsesValue = String(formData.get("maxUses") || "").trim();

    await submitWithSchema({
      schema: StudentInviteExportSchema,
      payload: {
        expiresAt: expiresDate
          ? new Date(`${expiresDate}T23:59:59`).toISOString()
          : "",
        maxUses: Number(maxUsesValue),
      },
      action: async (data) => {
        const response = await exportStudentInvitesByCourseAction(
          schoolId,
          courseId,
          data,
        );

        if (!response.ok) {
          return response;
        }

        const binaryString = atob(response.data.base64);
        const bytes = new Uint8Array(binaryString.length);
        for (let i = 0; i < binaryString.length; i += 1) {
          bytes[i] = binaryString.charCodeAt(i);
        }

        const blob = new Blob([bytes], { type: response.data.contentType });
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = url;
        link.download = response.data.fileName;
        document.body.appendChild(link);
        link.click();
        link.remove();
        URL.revokeObjectURL(url);

        return { ok: true };
      },
      onSuccess: () => {
        appToast.success("Codigos generados y descargados correctamente");
        setOpen(false);
      },
    });
  };

  return (
    <>
      <PrimaryActionButton className="h-10 rounded-lg px-4 text-sm" onClick={() => setOpen(true)}>
        Generar codigos de vinculacion
      </PrimaryActionButton>

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Generar codigos de vinculacion"
        description="Configura la expiracion y usos maximos para el lote de codigos del curso."
      >
        <form action={handleSubmit} className="space-y-6">
          <FormDateField id="expiresDate" name="expiresDate" label="Fecha de expiracion" required />
          <FormTextField
            id="maxUses"
            name="maxUses"
            type="number"
            min={1}
            step={1}
            defaultValue={2}
            label="Cantidad maxima de usos"
            required
          />

          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <ModalSecondaryButton onClick={() => setOpen(false)}>Cancelar</ModalSecondaryButton>
            <SubmitButton
              pendingText="Generando..."
              className="h-12 bg-[#1E3A5F] px-5 font-semibold text-white hover:bg-[#152B47]"
            >
              Generar y descargar
            </SubmitButton>
          </div>
        </form>
      </AppModal>
    </>
  );
}
