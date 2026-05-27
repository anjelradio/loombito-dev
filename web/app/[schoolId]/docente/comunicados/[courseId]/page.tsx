import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { communicationRepository } from "@/features/communications/data/repositories";
import TeacherCommunicationStudentCard from "@/features/communications/presentation/components/TeacherCommunicationStudentCard";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function DocenteComunicadosCoursePage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string; courseId: string }>;
  searchParams: Promise<{ courseName?: string }>;
}) {
  const { schoolId, courseId } = await params;
  const filters = await searchParams;
  const courseName = filters.courseName ?? "Curso";

  const studentsResponse = await communicationRepository.getTeacherCommunicationStudentsByCourse(
    schoolId,
    courseId,
  );

  if (!studentsResponse.ok) {
    throw new Error(studentsResponse.errors[0] ?? "Error al obtener estudiantes del curso.");
  }

  const students = studentsResponse.data;

  return (
    <>
      <SchoolPageHeader section="Docente" page="Comunicados" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Estudiantes del curso"
          description={`Selecciona un estudiante de ${courseName} para gestionar sus comunicados.`}
          tone="light"
          returnHref={`/${schoolId}/docente/comunicados`}
          returnLabel="Volver a cursos"
        />

        <AccentCard
          variant="base"
          eyebrow="Estudiantes"
          title="Selecciona un estudiante"
          description="Accede al historial de comunicados y crea nuevos registros."
          className="p-6"
        >
          {students.length ? (
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {students.map((student) => (
                <TeacherCommunicationStudentCard
                  key={student.id}
                  schoolId={schoolId}
                  courseId={courseId}
                  courseName={courseName}
                  student={student}
                />
              ))}
            </div>
          ) : (
            <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
              No hay estudiantes activos en este curso.
            </div>
          )}
        </AccentCard>
      </ContentGridSurface>
    </>
  );
}
