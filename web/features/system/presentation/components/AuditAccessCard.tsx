"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import { FormTextField } from "@/features/shared/components/forms/FormTextField";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import AppModal from "@/features/shared/components/modals/AppModal";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import { appToast } from "@/features/shared/components/toast/toast";
import PrimaryActionButton from "@/features/shared/components/ui/PrimaryActionButton";
import { requestAuditAccessKey } from "../actions/request-audit-access-action";
import { verifyAuditAccessKey } from "../actions/verify-audit-access-action";

export default function AuditAccessCard() {
  const router = useRouter();
  const [open, setOpen] = useState(false);

  const handleRequest = () => {
    void (async () => {
      const result = await requestAuditAccessKey();
      if (!result.ok) {
        appToast.error(result.errors[0] ?? "No se pudo solicitar la llave de acceso");
        return;
      }
      appToast.success("Se envio la llave de acceso a tu correo");
      setOpen(true);
    })();
  };

  const handleVerify = async (formData: FormData) => {
    const accessKey = String(formData.get("accessKey") ?? "").trim();
    if (!accessKey) {
      appToast.error("Ingresa la llave de acceso");
      return;
    }

    const result = await verifyAuditAccessKey(accessKey);
    if (!result.ok) {
      appToast.error(result.errors[0] ?? "No se pudo verificar la llave de acceso");
      return;
    }

    appToast.success("Acceso a bitacora verificado");
    setOpen(false);
    router.refresh();
  };

  return (
    <>
      <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-5 text-[#315a85]">
        <p className="text-sm">
          Para visualizar la bitacora debes solicitar y verificar una llave temporal.
        </p>
        <PrimaryActionButton onClick={handleRequest} className="mt-3">
          Solicitar llave de acceso
        </PrimaryActionButton>
      </div>

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Verificar llave de acceso"
        description="Ingresa la llave enviada a tu correo para abrir la bitacora de esta escuela."
        size="md"
      >
        <form action={handleVerify} className="space-y-6">
          <FormTextField
            id="accessKey"
            name="accessKey"
            label="Llave de acceso"
            placeholder="Ingresa la llave"
            autoComplete="off"
          />

          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <ModalSecondaryButton onClick={() => setOpen(false)}>Cancelar</ModalSecondaryButton>
            <SubmitButton
              pendingText="Verificando..."
              className="h-12 bg-[#1E3A5F] px-5 font-semibold text-white hover:bg-[#152B47]"
            >
              Verificar llave
            </SubmitButton>
          </div>
        </form>
      </AppModal>
    </>
  );
}
