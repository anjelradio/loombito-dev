import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { communicationRepository } from "@/features/communications/data/repositories";
import TeacherCommunicationCourseCard from "@/features/communications/presentation/components/TeacherCommunicationCourseCard";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import IndicatorsSummaryCard from "@/features/shared/components/cards/IndicatorsSummaryCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function DocenteComunicadosPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const response = await communicationRepository.getTeacherCommunicationCourses(schoolId);

  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al obtener cursos para comunicados.");
  }

  const courses = response.data;

  return (
    <>
      <SchoolPageHeader section="Docente" page="Comunicados" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Comunicados"
          description="Selecciona un curso para gestionar comunicados por estudiante."
          tone="light"
        />

        <section className="grid gap-5 xl:grid-cols-[minmax(260px,30%)_minmax(0,70%)]">
          <div className="space-y-5">
            <IndicatorsSummaryCard
              eyebrow="Panorama"
              title="Tu jornada"
              description="Cursos disponibles para crear y administrar comunicados."
              items={[
                {
                  label: "Cursos",
                  value: courses.length,
                  hint: "Con asignaciones activas",
                },
              ]}
            />

            <AccentCard
              variant="softBlue"
              eyebrow="Flujo"
              title="Ruta sugerida"
              description="Selecciona un curso, elige un estudiante y crea comunicados con titulo y descripcion."
            >
              <div className="rounded-xl border border-[#c7dbf1] bg-white p-4 text-sm text-[#456a92]">
                Esta seccion conecta la gestion de comunicados con tus cursos activos.
              </div>
            </AccentCard>
          </div>

          <AccentCard
            variant="base"
            eyebrow="Cursos"
            title="Selecciona un curso"
            description="Haz clic en un curso para ver su listado de estudiantes."
            className="p-6"
          >
            {courses.length ? (
              <div className="grid gap-3 sm:grid-cols-2">
                {courses.map((course) => (
                  <TeacherCommunicationCourseCard
                    key={course.id}
                    schoolId={schoolId}
                    course={course}
                  />
                ))}
              </div>
            ) : (
              <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                Aun no tienes cursos habilitados para comunicados.
              </div>
            )}
          </AccentCard>
        </section>
      </ContentGridSurface>
    </>
  );
}
