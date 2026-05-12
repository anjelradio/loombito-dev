import Link from "next/link";

import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { evaluationRepository } from "@/features/evaluations/data/repositories/evaluation.repository";
import { intelligenceRepository } from "@/features/intelligence/data/repositories/intelligence.repository";
import RecalculateStudentClustersButton from "@/features/intelligence/presentation/components/RecalculateStudentClustersButton";
import StudentClusterList from "@/features/intelligence/presentation/components/StudentClusterList";
import StudentClusterSummaryCard from "@/features/intelligence/presentation/components/StudentClusterSummaryCard";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function DocenteClasificacionAssignmentPage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string; assignmentId: string }>;
  searchParams: Promise<{ term?: string }>;
}) {
  const { schoolId, assignmentId } = await params;
  const { term } = await searchParams;

  const termOptionsResponse = await evaluationRepository.getTermAverageOptions(schoolId);
  if (!termOptionsResponse.ok) {
    throw new Error(termOptionsResponse.errors[0] ?? "No se pudieron obtener los trimestres.");
  }

  const termOptions = termOptionsResponse.data;
  const activeTerm = termOptions.find((item) => item.isActive) ?? termOptions[0] ?? null;
  const selectedTerm = termOptions.find((item) => item.name === term) ?? activeTerm ?? termOptions[0] ?? null;

  const snapshotResponse = selectedTerm
    ? await intelligenceRepository.getStudentClusters(schoolId, assignmentId, selectedTerm.id)
    : { ok: true as const, data: null };

  if (!snapshotResponse.ok) {
    throw new Error(snapshotResponse.errors[0] ?? "No se pudo obtener la clasificacion.");
  }

  const snapshot = snapshotResponse.data;

  return (
    <>
      <SchoolPageHeader section="Analiticas" page="Clasificacion" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Clasificacion de estudiantes"
          description="Agrupacion por rendimiento final y asistencia del trimestre seleccionado."
          tone="light"
          returnHref={`/${schoolId}/docente/analiticas/clasificacion`}
          returnLabel="Volver a clasificacion"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[60%_40%]">
          <AccentCard variant="base" eyebrow="Estudiantes" className="min-h-[580px] p-5">
            <div className="mb-3 flex justify-end">
              <RecalculateStudentClustersButton
                schoolId={schoolId}
                assignmentId={assignmentId}
                termId={selectedTerm?.id ?? null}
              />
            </div>

            <StudentClusterList rows={snapshot?.students ?? []} />
          </AccentCard>

          <div className="space-y-5">
            <AccentCard variant="softBlue" eyebrow="Trimestres" title="Seleccion de trimestre">
              <div className="flex flex-wrap gap-2">
                {termOptions.map((term) => {
                  const isSelected = selectedTerm?.id === term.id;
                  return (
                    <Link
                      key={term.id}
                      href={`/${schoolId}/docente/analiticas/clasificacion/${assignmentId}?term=${encodeURIComponent(term.name)}`}
                      className={`rounded-full border px-3 py-1.5 text-xs font-semibold transition-colors ${
                        isSelected
                          ? "border-[#1E3A5F] bg-[#1E3A5F] text-white"
                          : "border-[#c7dbf1] bg-white text-[#355f89] hover:bg-[#f0f7ff]"
                      }`}
                    >
                      {term.name}
                    </Link>
                  );
                })}
              </div>
            </AccentCard>

            {snapshot ? (
              <StudentClusterSummaryCard snapshot={snapshot} selectedTermName={selectedTerm?.name ?? "--"} />
            ) : null}

            <AccentCard variant="softBlue" eyebrow="Proximo" title="Implementacion futura">
              <div className="rounded-xl border border-[#c7dbf1] bg-white p-4 text-sm text-[#456a92]">
                Aqui agregaremos recomendaciones de refuerzo y alertas para estudiantes en riesgo.
              </div>
            </AccentCard>
          </div>
        </section>
      </ContentGridSurface>
    </>
  );
}
