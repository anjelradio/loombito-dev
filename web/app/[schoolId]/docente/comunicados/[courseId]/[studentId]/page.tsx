import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ScrollArea } from "@/components/ui/scroll-area";
import { communicationRepository } from "@/features/communications/data/repositories";
import CreateStudentCommunicationButton from "@/features/communications/presentation/components/CreateStudentCommunicationButton";
import StudentCommunicationListItemCard from "@/features/communications/presentation/components/StudentCommunicationListItemCard";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import IndicatorsSummaryCard from "@/features/shared/components/cards/IndicatorsSummaryCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function StudentCommunicationsPage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string; courseId: string; studentId: string }>;
  searchParams: Promise<{ courseName?: string; studentName?: string }>;
}) {
  const { schoolId, courseId, studentId } = await params;
  const filters = await searchParams;
  const courseName = filters.courseName ?? "Curso";
  const studentName = filters.studentName ?? "Estudiante";

  const response = await communicationRepository.getStudentCommunications(schoolId, studentId);

  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al obtener comunicados del estudiante.");
  }

  const communications = response.data;

  return (
    <>
      <SchoolPageHeader section="Docente" page="Comunicados" />
      <ContentGridSurface variant="mist">
        <PageHeading
          title={`Comunicados de ${studentName}`}
          description={`Gestiona publicaciones del estudiante en ${courseName}.`}
          tone="light"
          returnHref={`/${schoolId}/docente/comunicados/${courseId}?courseName=${encodeURIComponent(courseName)}`}
          returnLabel="Volver a estudiantes"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[30%_70%]">
          <div className="space-y-5">
            <IndicatorsSummaryCard
              eyebrow="Estado"
              title="Resumen de publicaciones"
              description="Panorama actual de comunicados enviados para este estudiante."
              items={[
                { label: "Total", value: communications.length },
                {
                  label: "Recientes (7 dias)",
                  value: communications.filter(
                    (item) =>
                      Date.now() - new Date(item.createdDate).getTime() <= 7 * 24 * 60 * 60 * 1000,
                  ).length,
                },
              ]}
            />

            <AccentCard
              variant="softBlue"
              eyebrow="Contexto"
              title="Seguimiento familiar"
              description="Cada comunicado enviado se refleja como notificacion para los tutores vinculados."
            />
          </div>

          <AccentCard variant="base" eyebrow="Listado" className="flex min-h-[460px] flex-col p-5">
            <div className="mb-4 flex justify-end">
              <CreateStudentCommunicationButton schoolId={schoolId} studentId={studentId} />
            </div>

            <ScrollArea className="h-[380px] pr-3">
              <div className="space-y-3 pb-1">
                {communications.length ? (
                  communications.map((communication) => (
                    <StudentCommunicationListItemCard
                      key={communication.id}
                      schoolId={schoolId}
                      communication={communication}
                    />
                  ))
                ) : (
                  <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                    Aun no hay comunicados para este estudiante.
                  </div>
                )}
              </div>
            </ScrollArea>
          </AccentCard>
        </section>
      </ContentGridSurface>
    </>
  );
}
