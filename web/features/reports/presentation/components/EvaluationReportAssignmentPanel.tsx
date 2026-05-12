"use client";

import { useMemo, useState } from "react";

import type { TeacherAssignmentContextCourseGroup } from "@/features/academic/domain/entities/teacher-assignment-context";
import { reportBrowserRepository } from "@/features/reports/data/repositories/report-browser.repository";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import AppModal from "@/features/shared/components/modals/AppModal";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import { appToast } from "@/features/shared/components/toast/toast";
import SelectableChips from "@/features/shared/components/ui/SelectableChips";

import ReportAssignmentGroupsSelectorCard from "./ReportAssignmentGroupsSelectorCard";

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

type EvaluationReportAssignmentPanelProps = {
  schoolId: string;
  groups: TeacherAssignmentContextCourseGroup[];
};

export default function EvaluationReportAssignmentPanel({
  schoolId,
  groups,
}: EvaluationReportAssignmentPanelProps) {
  const [open, setOpen] = useState(false);
  const [assignmentId, setAssignmentId] = useState("");
  const [courseName, setCourseName] = useState("");
  const [subjectName, setSubjectName] = useState("");
  const [format, setFormat] = useState<"xlsx" | "pdf">("xlsx");
  const [columns, setColumns] = useState<string[]>(reportColumns.map((item) => item.value));

  const canSubmit = useMemo(() => columns.length > 0 && !!assignmentId, [columns, assignmentId]);

  const handleSelectAssignment = async (nextAssignmentId: string, nextCourseName: string, nextSubjectName: string) => {
    setAssignmentId(nextAssignmentId);
    setCourseName(nextCourseName);
    setSubjectName(nextSubjectName);
    setOpen(true);
  };

  const handleSubmit = async (formData: FormData) => {
    const summary = String(formData.get("summary") || "").trim();

    if (!assignmentId) {
      appToast.error("Selecciona una materia");
      return;
    }
    if (!columns.length) {
      appToast.error("Selecciona al menos una columna");
      return;
    }
    const response = await reportBrowserRepository.exportEvaluationReport({
      schoolId,
      assignmentId,
      columns,
      format,
      summary: summary || null,
    });

    if (!response.ok) {
      appToast.error(response.errors[0] ?? "No se pudo generar el reporte");
      return;
    }

    const url = URL.createObjectURL(response.data.blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = response.data.fileName;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);

    appToast.success("Reporte generado y descargado");
    setOpen(false);
  };

  return (
    <>
      <ReportAssignmentGroupsSelectorCard groups={groups} onSelect={handleSelectAssignment} />

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title={`Reporte de evaluaciones: ${subjectName}`}
        description={`Curso: ${courseName}. Se incluiran todas las evaluaciones activas de la materia.`}
        size="xl"
      >
        <form action={handleSubmit} className="space-y-5">
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
