"use client";

import { useMemo, useState } from "react";

import AppModal from "@/features/shared/components/modals/AppModal";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import SelectableChips from "@/features/shared/components/ui/SelectableChips";
import { appToast } from "@/features/shared/components/toast/toast";

const reportColumns = [
  { value: "student_last_name", label: "Apellido" },
  { value: "student_first_name", label: "Nombre" },
  { value: "score", label: "Calificacion" },
  { value: "status", label: "Estado" },
  { value: "evaluation_name", label: "Evaluacion" },
  { value: "term_name", label: "Trimestre" },
  { value: "course_name", label: "Curso" },
  { value: "subject_name", label: "Materia" },
] as const;

type GenerateEvaluationReportButtonProps = {
  schoolId: string;
};

export default function GenerateEvaluationReportButton({ schoolId }: GenerateEvaluationReportButtonProps) {
  const [open, setOpen] = useState(false);
  const [format, setFormat] = useState<"xlsx" | "pdf">("xlsx");
  const [columns, setColumns] = useState<string[]>(reportColumns.map((item) => item.value));

  const canSubmit = useMemo(() => columns.length > 0, [columns]);

  const handleSubmit = async (formData: FormData) => {
    const evaluationId = String(formData.get("evaluationId") || "").trim();
    const summary = String(formData.get("summary") || "").trim();

    if (!evaluationId) {
      appToast.error("Ingresa el ID de la evaluacion");
      return;
    }
    if (!columns.length) {
      appToast.error("Selecciona al menos una columna");
      return;
    }

    if (format === "pdf") {
      appToast.error("Exportacion PDF disponible en la siguiente etapa");
      return;
    }

    const response = await fetch("/api/reports/export/evaluation", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        schoolId,
        evaluationId,
        columns,
        format,
        summary: summary || null,
      }),
    });

    if (!response.ok) {
      const data = await response.json().catch(() => null);
      appToast.error(data?.message ?? "No se pudo generar el reporte");
      return;
    }

    const blob = await response.blob();
    const disposition = response.headers.get("content-disposition") || "";
    const fileNameMatch = disposition.match(/filename="([^"]+)"/);
    const fileName = fileNameMatch?.[1] ?? "reporte_evaluaciones.xlsx";
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);

    appToast.success("Reporte generado y descargado");
    setOpen(false);
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="h-10 rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white hover:bg-[#152B47]"
      >
        Generar reporte
      </button>

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title="Generar reporte de evaluaciones"
        description="Configura el reporte, selecciona columnas y descarga el archivo."
        size="xl"
      >
        <form action={handleSubmit} className="space-y-5">
          <div className="space-y-2">
            <label htmlFor="evaluationId" className="text-sm font-semibold text-[#1E3A5F]">
              ID de evaluacion
            </label>
            <input
              id="evaluationId"
              name="evaluationId"
              placeholder="UUID de la evaluacion"
              className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]"
              required
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="summary" className="text-sm font-semibold text-[#1E3A5F]">
              Descripcion (opcional)
            </label>
            <input
              id="summary"
              name="summary"
              placeholder="Ej: Reporte mensual de evaluaciones"
              className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]"
            />
          </div>

          <div className="space-y-2">
            <p className="text-sm font-semibold text-[#1E3A5F]">Formato</p>
            <SelectableChips
              options={[
                { value: "xlsx", label: "Excel" },
                { value: "pdf", label: "PDF" },
              ]}
              selectedValues={[format]}
              onChange={(values) => setFormat((values[0] as "xlsx" | "pdf") || "xlsx")}
            />
          </div>

          <div className="space-y-2">
            <p className="text-sm font-semibold text-[#1E3A5F]">Columnas</p>
            <SelectableChips
              options={reportColumns.map((item) => ({ value: item.value, label: item.label }))}
              selectedValues={columns}
              onChange={(values) => setColumns(values)}
              multiple
            />
          </div>

          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <ModalSecondaryButton onClick={() => setOpen(false)}>Cerrar</ModalSecondaryButton>
            <SubmitButton
              disabled={!canSubmit}
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
