"use client";

import { useState } from "react";
import { Student } from "@/features/students/domain/entities/student";
import { FileDown, Loader2 } from "lucide-react";
import { appToast } from "@/features/shared/components/toast/toast";
import { exportBoletinAction } from "@/app/[schoolId]/academico/reportes/boletines/actions";

interface Props {
  student: Student;
  courseId: string;
  schoolId: string;
}

export default function BoletinesStudentItem({ student, courseId, schoolId }: Props) {
  const [isDownloading, setIsDownloading] = useState(false);

  const handleDownload = async () => {
    setIsDownloading(true);
    appToast.loading("Generando boletín...");
    try {
      const result = await exportBoletinAction(schoolId, courseId, student.id);
      
      appToast.dismiss();
      
      if (!result.ok) {
        appToast.error(result.error || "Hubo un error al generar el boletín");
        return;
      }

      const { base64, contentType, fileName } = result.data;
      const link = document.createElement("a");
      link.href = `data:${contentType};base64,${base64}`;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      appToast.success("Boletín generado con éxito");
    } catch (error) {
      appToast.dismiss();
      appToast.error("Error de red al intentar descargar el boletín");
    } finally {
      setIsDownloading(false);
    }
  };

  return (
    <div className="group flex items-center justify-between rounded-xl border border-[#d5e3f3] bg-white p-4 px-5 hover:border-[#6a8cb2] transition-all duration-200 shadow-sm hover:shadow-md">
      <div>
        <p className="text-base font-semibold text-[#1f4d7d]">
          {student.lastName} {student.firstName}
        </p>
        <p className="text-xs text-[#5b7ea5] mt-1 font-medium">
          Fecha de nac: {new Date(student.birthDate).toLocaleDateString("es-ES", {
            day: "2-digit",
            month: "short",
            year: "numeric",
          })}
        </p>
      </div>
      <button
        onClick={handleDownload}
        disabled={isDownloading}
        className="flex items-center justify-center h-10 w-10 rounded-full bg-[#eef6ff] text-[#2b5f97] hover:bg-[#1f4d7d] hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        title="Generar boletín"
      >
        {isDownloading ? (
          <Loader2 className="h-4 w-4 animate-spin" />
        ) : (
          <FileDown className="h-4 w-4" />
        )}
      </button>
    </div>
  );
}
