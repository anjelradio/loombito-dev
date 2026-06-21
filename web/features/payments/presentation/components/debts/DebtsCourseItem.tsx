"use client";

import { useState, useEffect } from "react";
import { Course } from "@/features/academic/domain/entities/course";
import { Student } from "@/features/students/domain/entities/student";
import { getCourseStudentsAction } from "@/app/[schoolId]/academico/reportes/boletines/actions";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetDescription, SheetTrigger } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { appToast } from "@/features/shared/components/toast/toast";
import DebtsStudentItem from "./DebtsStudentItem";

interface Props {
  schoolId: string;
  course: Course;
}

export default function DebtsCourseItem({ schoolId, course }: Props) {
  const [open, setOpen] = useState(false);
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (open && students.length === 0) {
      setLoading(true);
      getCourseStudentsAction(schoolId, course.id, 1, 50)
        .then((res) => {
          if (res.ok) {
            setStudents(res.data.students);
          } else {
            appToast.error(res.errors[0] || "Error al cargar estudiantes");
          }
        })
        .finally(() => setLoading(false));
    }
  }, [open, course.id, schoolId, students.length]);

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <button
          type="button"
          className="w-full flex cursor-pointer list-none items-center justify-between gap-3 rounded-xl border border-[#d5e3f3] bg-[#f8fbff] px-4 py-3.5 text-left hover:bg-[#eef6ff] transition-colors"
        >
          <div>
            <p className="text-xs uppercase tracking-[0.14em] text-[#6a8cb2]">Curso</p>
            <p className="mt-1 text-base font-semibold text-[#1f4d7d]">{course.name}</p>
          </div>
          <div className="text-right">
            <p className="text-xs uppercase tracking-[0.12em] text-[#6a8cb2]">Nivel</p>
            <p className="mt-0.5 text-sm font-semibold text-[#2b5f97]">{course.levelName}</p>
          </div>
        </button>
      </SheetTrigger>

      <SheetContent className="sm:max-w-xl w-full sm:w-[600px] bg-[#f8fbff] border-l-[#d5e3f3] flex flex-col sm:p-8">
        <SheetHeader className="px-2">
          <SheetTitle className="text-2xl font-bold tracking-tight text-[#1E3A5F]">
            Estudiantes de {course.name}
          </SheetTitle>
          <SheetDescription className="text-sm font-medium text-[#6a8cb2] mt-1">
            Selecciona un estudiante para consultar sus deudas y estado de cuenta.
          </SheetDescription>
        </SheetHeader>
        
        <div className="mt-8 flex-1 overflow-y-auto px-2 pr-4">
          {loading ? (
            <div className="space-y-4">
              {[1, 2, 3, 4, 5].map((i) => (
                <div key={i} className="flex items-center justify-between rounded-xl border border-[#d5e3f3] bg-white p-4 px-5">
                  <div className="space-y-2">
                    <Skeleton className="h-4 w-32" />
                    <Skeleton className="h-3 w-20" />
                  </div>
                  <Skeleton className="h-9 w-9 rounded-full" />
                </div>
              ))}
            </div>
          ) : students.length > 0 ? (
            <div className="space-y-4">
              {students.map((student) => (
                <DebtsStudentItem key={student.id} student={student} schoolId={schoolId} />
              ))}
            </div>
          ) : (
            <div className="flex items-center justify-center h-48 rounded-lg border-2 border-dashed border-[#d5e3f3] bg-white">
              <p className="text-sm text-[#5b7ea5]">No hay estudiantes registrados en este curso.</p>
            </div>
          )}
        </div>
      </SheetContent>
    </Sheet>
  );
}
