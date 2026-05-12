"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { schoolBackupBrowserRepository } from "@/features/system/data/repositories/school-backup-browser.repository";
import { appToast } from "@/features/shared/components/toast/toast";

type CreateSchoolBackupButtonProps = {
  schoolId: string;
};

export default function CreateSchoolBackupButton({ schoolId }: CreateSchoolBackupButtonProps) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleCreate = async () => {
    setLoading(true);
    const response = await schoolBackupBrowserRepository.createSchoolBackup(schoolId);
    setLoading(false);

    if (!response.ok) {
      appToast.error(response.errors[0] ?? "No se pudo crear la copia de seguridad");
      return;
    }

    appToast.success("Copia de seguridad creada");
    router.refresh();
  };

  return (
    <button
      type="button"
      onClick={handleCreate}
      disabled={loading}
      className="h-10 rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white hover:bg-[#152B47] disabled:cursor-not-allowed disabled:opacity-70"
    >
      {loading ? "Creando..." : "Crear copia de seguridad"}
    </button>
  );
}
