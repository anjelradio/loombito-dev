import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { assignmentRepository } from "@/features/academic/data/repositories/assignment.repository";
import { reportRepository } from "@/features/reports/data/repositories/report.repository";
import EvaluationReportAssignmentPanel from "@/features/reports/presentation/components/EvaluationReportAssignmentPanel";
import ReportRunsListPlaceholder from "@/features/reports/presentation/components/ReportRunsListPlaceholder";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function AcademicoReportesEvaluacionesPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const runsResponse = await reportRepository.getRunsBySchool(schoolId, "evaluation_gradebook_report");
  const groupsResponse = await assignmentRepository.getAssignmentGroupsForContext(schoolId);

  if (!runsResponse.ok) {
    throw new Error(runsResponse.errors[0] ?? "No se pudieron obtener reportes de evaluaciones.");
  }
  if (!groupsResponse.ok) {
    throw new Error(groupsResponse.errors[0] ?? "No se pudieron obtener las asignaciones.");
  }

  return (
    <>
      <SchoolPageHeader section="Academico" page="Reportes" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Reporte de evaluaciones"
          description="Prepara reportes de calificaciones por evaluacion y estado de registro por estudiante."
          tone="light"
          returnHref={`/${schoolId}/academico/reportes`}
          returnLabel="Volver a reportes"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[60%_40%]">
          <ReportRunsListPlaceholder
            title="Reportes de evaluaciones"
            runs={runsResponse.data}
          />

          <EvaluationReportAssignmentPanel schoolId={schoolId} groups={groupsResponse.data} />
        </section>
      </ContentGridSurface>
    </>
  );
}
