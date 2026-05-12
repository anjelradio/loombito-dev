"use client";

import { useTransition } from "react";
import { useRouter } from "next/navigation";

import { appToast } from "@/features/shared/components/toast/toast";
import { recalculateStudentClusters } from "@/features/intelligence/presentation/actions/recalculate-student-clusters-action";

type RecalculateStudentClustersButtonProps = {
  schoolId: string;
  assignmentId: string;
  termId: string | null;
};

export default function RecalculateStudentClustersButton({
  schoolId,
  assignmentId,
  termId,
}: RecalculateStudentClustersButtonProps) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const handleClick = () => {
    if (!termId) {
      appToast.error("Selecciona un trimestre para calcular");
      return;
    }

    startTransition(async () => {
      const result = await recalculateStudentClusters(schoolId, assignmentId, termId);
      if (!result.ok) {
        appToast.error(result.errors[0] ?? "No se pudo recalcular la clasificacion");
        return;
      }
      appToast.success("Clasificacion calculada correctamente");
      router.refresh();
    });
  };

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={isPending || !termId}
      className="h-10 rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white hover:bg-[#152B47] disabled:cursor-not-allowed disabled:opacity-60"
    >
      {isPending ? "Calculando..." : "Calcular"}
    </button>
  );
}
