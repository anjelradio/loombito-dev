"use client";

import type { TeacherAssignmentContextCourseGroup } from "@/features/academic/domain/entities/teacher-assignment-context";
import { ScrollArea } from "@/components/ui/scroll-area";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";

type ReportAssignmentGroupsSelectorCardProps = {
  groups: TeacherAssignmentContextCourseGroup[];
  onSelect: (assignmentId: string, courseName: string, subjectName: string) => void;
};

export default function ReportAssignmentGroupsSelectorCard({
  groups,
  onSelect,
}: ReportAssignmentGroupsSelectorCardProps) {
  return (
    <AccentCard
      variant="base"
      eyebrow="Asignaciones"
      title="Cursos y materias"
      description="Selecciona una materia para abrir el formulario de reporte en modal."
      className="p-5"
    >
      {groups.length ? (
        <ScrollArea className="h-[360px] pr-3">
          <div className="space-y-3 pb-1">
            {groups.map((group) => (
              <details key={group.courseId} className="group rounded-xl border border-[#d5e3f3] bg-[#f8fbff] open:bg-[#f5faff]">
                <summary className="flex cursor-pointer list-none items-center justify-between gap-3 px-4 py-3.5 marker:content-none">
                  <div>
                    <p className="text-xs uppercase tracking-[0.14em] text-[#6a8cb2]">Curso</p>
                    <p className="mt-1 text-base font-semibold text-[#1f4d7d]">{group.courseName}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs uppercase tracking-[0.12em] text-[#6a8cb2]">Materias</p>
                    <p className="mt-0.5 text-sm font-semibold text-[#2b5f97]">{group.subjects.length}</p>
                  </div>
                </summary>

                <div className="border-t border-[#d5e3f3] px-4 py-4">
                  <div className="grid gap-2.5 sm:grid-cols-2 xl:grid-cols-3">
                    {group.subjects.map((subject) => (
                      <button
                        key={subject.assignmentId}
                        type="button"
                        onClick={() => onSelect(subject.assignmentId, group.courseName, subject.subjectName)}
                        className="rounded-xl border border-[#d5e3f3] bg-white p-3 text-left hover:bg-[#eef6ff]"
                      >
                        <p className="text-sm font-semibold text-[#1f4d7d]">{subject.subjectName}</p>
                        <p className="mt-1 text-xs text-[#5b7ea5]">Abrir formulario de reporte</p>
                      </button>
                    ))}
                  </div>
                </div>
              </details>
            ))}
          </div>
        </ScrollArea>
      ) : (
        <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
          Aun no hay asignaciones activas para generar reportes.
        </div>
      )}
    </AccentCard>
  );
}
