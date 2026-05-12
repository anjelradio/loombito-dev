import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { assignmentRepository } from "@/features/academic/data/repositories/assignment.repository";
import TeacherAssignmentGroupsCard from "@/features/academic/presentation/components/teacher-assignment/TeacherAssignmentGroupsCard";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import IndicatorsSummaryCard from "@/features/shared/components/cards/IndicatorsSummaryCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function DocenteClasificacionPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const response = await assignmentRepository.getAssignmentGroupsForContext(schoolId);

  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al obtener asignaciones.");
  }

  return (
    <>
      <SchoolPageHeader section="Analiticas" page="Clasificacion" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Clasificacion de estudiantes"
          description="Selecciona una materia para calcular y consultar agrupaciones por rendimiento y asistencia."
          tone="light"
        />

        <div className="grid gap-5 xl:grid-cols-[minmax(260px,30%)_minmax(0,70%)]">
          <div className="space-y-5">
            <IndicatorsSummaryCard
              eyebrow="Panorama"
              title="Resumen rapido"
              description="Vista general para monitorear el comportamiento academico del grupo."
              items={[
                { label: "Materias", value: `${response.data.reduce((acc, group) => acc + group.subjects.length, 0)}` },
                { label: "Cursos", value: `${response.data.length}` },
              ]}
            />

            <AccentCard
              variant="softBlue"
              eyebrow="Proximo"
              title="Explicabilidad"
              description="En la siguiente fase mostraremos motivos detallados por estudiante."
            >
              <div className="rounded-xl border border-[#c7dbf1] bg-white p-4 text-sm text-[#456a92]">
                Este bloque queda listo para recomendaciones y alertas tempranas.
              </div>
            </AccentCard>
          </div>

          <TeacherAssignmentGroupsCard
            schoolId={schoolId}
            mode="clasificacion"
            basePath="docente/analiticas/clasificacion"
            groups={response.data}
          />
        </div>
      </ContentGridSurface>
    </>
  );
}
