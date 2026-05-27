import Link from "next/link";

import type { TeacherCommunicationCourse } from "@/features/communications/domain/entities/student-communication";

type TeacherCommunicationCourseCardProps = {
  schoolId: string;
  course: TeacherCommunicationCourse;
};

export default function TeacherCommunicationCourseCard({
  schoolId,
  course,
}: TeacherCommunicationCourseCardProps) {
  return (
    <Link
      href={`/${schoolId}/docente/comunicados/${course.id}?courseName=${encodeURIComponent(course.name)}`}
      className="group rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 transition hover:border-[#b7d0ea] hover:bg-[#f1f7ff]"
    >
      <p className="text-xs uppercase tracking-[0.14em] text-[#6a8cb2]">Curso</p>
      <p className="mt-1 text-base font-semibold text-[#1f4d7d]">{course.name}</p>
      <p className="mt-2 text-xs font-medium text-[#4f7197] group-hover:text-[#2a5b8f]">
        Ver estudiantes
      </p>
    </Link>
  );
}
