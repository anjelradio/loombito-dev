import Link from "next/link";
import { ArrowUpRight } from "lucide-react";

import type { TeacherAssignmentContextSubject } from "@/features/academic/domain/entities/teacher-assignment-context";

type TeacherAssignmentSubjectCardProps = {
  schoolId: string;
  mode: "evaluaciones" | "asistencias" | "promedios" | "clasificacion";
  subject: TeacherAssignmentContextSubject;
  basePath?: string;
};

export default function TeacherAssignmentSubjectCard({
  schoolId,
  mode,
  subject,
  basePath,
}: TeacherAssignmentSubjectCardProps) {
  const href = basePath
    ? `/${schoolId}/${basePath}/${subject.assignmentId}`
    : `/${schoolId}/docente/${mode}/${subject.assignmentId}`;

  return (
    <Link
      href={href}
      className="group relative block overflow-hidden rounded-xl border border-[#cfe0f2] bg-[radial-gradient(120%_120%_at_0%_0%,#ffffff_0%,#f4f9ff_52%,#eaf3ff_100%)] p-4 shadow-[0_18px_34px_-30px_rgba(10,31,61,0.65)] transition-all duration-300 hover:-translate-y-0.5 hover:border-[#bcd6f1] hover:shadow-[0_26px_40px_-28px_rgba(10,31,61,0.62)]"
    >
      <div className="pointer-events-none absolute -right-6 -top-6 h-20 w-20 rounded-full bg-[#d9eafe]/70 blur-xl transition-transform duration-300 group-hover:scale-110" />
      <div className="pointer-events-none absolute -bottom-8 -left-4 h-16 w-24 rounded-full bg-[#d7e8fc]/60 blur-xl" />

      <div className="relative min-h-[80px]">
        <div className="flex items-start justify-between gap-3">
          <p className="text-xs uppercase tracking-[0.14em] text-[#5f82aa]">Materia</p>
          <span className="h-px w-14 self-center bg-gradient-to-r from-[#cfe0f2] to-transparent" />
        </div>

        <div className="mt-2.5 flex items-center justify-between gap-3">
          <p className="line-clamp-3 text-base font-semibold leading-snug text-[#1f4d7d] sm:text-[1.03rem]">
            {subject.subjectName}
          </p>

          <span className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border border-[#cfe0f2] bg-white text-[#2b5f97] transition-transform duration-300 group-hover:-translate-y-0.5 group-hover:translate-x-0.5">
            <ArrowUpRight className="h-4 w-4" />
          </span>
        </div>
      </div>
    </Link>
  );
}
