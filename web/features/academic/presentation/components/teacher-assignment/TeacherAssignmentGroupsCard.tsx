import type { TeacherAssignmentContextCourseGroup } from "@/features/academic/domain/entities/teacher-assignment-context";
import { ScrollArea } from "@/components/ui/scroll-area";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";

import TeacherAssignmentSubjectCard from "./TeacherAssignmentSubjectCard";

type TeacherAssignmentGroupsCardProps = {
  schoolId: string;
  mode: "evaluaciones" | "asistencias" | "promedios" | "clasificacion";
  groups: TeacherAssignmentContextCourseGroup[];
  basePath?: string;
};

export default function TeacherAssignmentGroupsCard({
  schoolId,
  mode,
  groups,
  basePath,
}: TeacherAssignmentGroupsCardProps) {
  return (
    <AccentCard
      variant="base"
      eyebrow="Mis asignaciones"
      title="Espacios de evaluacion"
      description="Revisa tus cursos y entra a cada materia para trabajar su cuaderno evaluativo."
      className="p-6"
    >
      {groups.length ? (
        <ScrollArea className="h-[460px] pr-3">
          <div className="space-y-4 pb-1">
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
                  <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                    {group.subjects.map((subject) => (
                      <TeacherAssignmentSubjectCard
                        key={subject.assignmentId}
                        schoolId={schoolId}
                        mode={mode}
                        subject={subject}
                        basePath={basePath}
                      />
                    ))}
                  </div>
                </div>
              </details>
            ))}
          </div>
        </ScrollArea>
      ) : (
        <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
          Aun no tienes asignaciones activas en esta escuela.
        </div>
      )}
    </AccentCard>
  );
}
