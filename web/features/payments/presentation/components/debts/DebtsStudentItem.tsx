"use client";

import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Student } from "@/features/students/domain/entities/student";

interface Props {
  schoolId: string;
  student: Student;
}

export default function DebtsStudentItem({ schoolId, student }: Props) {
  return (
    <Link
      href={`/${schoolId}/pagos/deudas/${student.id}`}
      className="group flex items-center justify-between rounded-xl border border-[#d5e3f3] bg-white p-4 px-5 transition-all hover:-translate-y-0.5 hover:shadow-md"
    >
      <div>
        <p className="font-semibold text-[#1f4d7d]">
          {student.lastName} {student.firstName}
        </p>
      </div>
      <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#f3f8ff] text-[#345b86] group-hover:bg-[#1E3A5F] group-hover:text-white transition-colors">
        <ChevronRight className="h-4 w-4" />
      </div>
    </Link>
  );
}
