"use client";

import { Course } from "@/features/academic/domain/entities/course";
import { ScrollArea } from "@/components/ui/scroll-area";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import DebtsCourseItem from "./DebtsCourseItem";

interface Props {
  schoolId: string;
  courses: Course[];
}

export default function DebtsCourseWorkspace({ schoolId, courses }: Props) {
  return (
    <AccentCard
      variant="base"
      eyebrow="Cursos"
      title="Listado de cursos"
      description="Selecciona un curso para buscar al estudiante y consultar su estado de cuenta."
      className="p-5"
    >
      {courses.length ? (
        <ScrollArea className="h-[65vh] pr-3">
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 pb-1">
            {courses.map((course) => (
              <DebtsCourseItem key={course.id} schoolId={schoolId} course={course} />
            ))}
          </div>
        </ScrollArea>
      ) : (
        <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
          Aun no hay cursos registrados.
        </div>
      )}
    </AccentCard>
  );
}
