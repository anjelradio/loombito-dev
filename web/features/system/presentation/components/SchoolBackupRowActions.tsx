"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { appToast } from "@/features/shared/components/toast/toast";
import { schoolBackupBrowserRepository } from "@/features/system/data/repositories/school-backup-browser.repository";

type SchoolBackupRowActionsProps = {
  schoolId: string;
  backupId: string;
  fileName: string;
};

export default function SchoolBackupRowActions({ schoolId, backupId, fileName }: SchoolBackupRowActionsProps) {
  const router = useRouter();
  const [loadingAction, setLoadingAction] = useState<"restore" | "delete" | null>(null);

  const handleRestore = async () => {
    const confirmed = window.confirm(`Restaurar la copia ${fileName}? Esta accion reemplaza todos los datos actuales del colegio.`);
    if (!confirmed) return;

    setLoadingAction("restore");
    const response = await schoolBackupBrowserRepository.restoreSchoolBackup(schoolId, backupId);
    setLoadingAction(null);

    if (!response.ok) {
      appToast.error(response.errors[0] ?? "No se pudo restaurar la copia");
      return;
    }

    appToast.success("Copia restaurada correctamente");
    router.refresh();
  };

  const handleDelete = async () => {
    const confirmed = window.confirm(`Eliminar la copia ${fileName}?`);
    if (!confirmed) return;

    setLoadingAction("delete");
    const response = await schoolBackupBrowserRepository.deleteSchoolBackup(schoolId, backupId);
    setLoadingAction(null);

    if (!response.ok) {
      appToast.error(response.errors[0] ?? "No se pudo eliminar la copia");
      return;
    }

    appToast.success("Copia eliminada");
    router.refresh();
  };

  return (
    <div className="mt-2 flex items-center gap-2">
      <button
        type="button"
        onClick={handleRestore}
        disabled={loadingAction !== null}
        className="h-8 rounded-md border border-[#b9cee6] px-3 text-xs font-semibold text-[#24598f] hover:bg-[#eef5ff] disabled:opacity-60"
      >
        {loadingAction === "restore" ? "Restaurando..." : "Restaurar"}
      </button>
      <button
        type="button"
        onClick={handleDelete}
        disabled={loadingAction !== null}
        className="h-8 rounded-md border border-[#ecc9c9] px-3 text-xs font-semibold text-[#9b3f3f] hover:bg-[#fff3f3] disabled:opacity-60"
      >
        {loadingAction === "delete" ? "Eliminando..." : "Eliminar"}
      </button>
    </div>
  );
}
