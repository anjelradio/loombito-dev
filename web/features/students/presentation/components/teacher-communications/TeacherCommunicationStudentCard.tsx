import Link from "next/link";

import type { TeacherCommunicationStudent } from "@/features/communications/domain/entities/student-communication";

type TeacherCommunicationStudentCardProps = {
  schoolId: string;
  courseId: string;
  courseName: string;
  student: TeacherCommunicationStudent;
};

export default function TeacherCommunicationStudentCard({
  schoolId,
  courseId,
  courseName,
  student,
}: TeacherCommunicationStudentCardProps) {
  return (
    <Link
      href={`/${schoolId}/docente/comunicados/${courseId}/${student.id}?courseName=${encodeURIComponent(courseName)}&studentName=${encodeURIComponent(`${student.lastName} ${student.firstName}`)}`}
      className="group rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 transition hover:border-[#b7d0ea] hover:bg-[#f1f7ff]"
    >
      <p className="text-xs uppercase tracking-[0.14em] text-[#6a8cb2]">Estudiante</p>
      <p className="mt-1 text-base font-semibold text-[#1f4d7d]">
        {student.lastName} {student.firstName}
      </p>
      <p className="mt-2 text-xs font-medium text-[#4f7197] group-hover:text-[#2a5b8f]">
        Ver comunicados
      </p>
    </Link>
  );
}
