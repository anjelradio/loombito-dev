import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { assignmentRepository } from "@/features/academic/data/repositories/assignment.repository";
import { reportRepository } from "@/features/reports/data/repositories/report.repository";
import AttendanceReportAssignmentPanel from "@/features/reports/presentation/components/AttendanceReportAssignmentPanel";
import ReportRunsListPlaceholder from "@/features/reports/presentation/components/ReportRunsListPlaceholder";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function AcademicoReportesAsistenciasPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const runsResponse = await reportRepository.getRunsBySchool(schoolId, "attendance_report");
  const groupsResponse = await assignmentRepository.getAssignmentGroupsForContext(schoolId);
  if (!runsResponse.ok) {
    throw new Error(runsResponse.errors[0] ?? "No se pudieron obtener reportes de asistencia.");
  }
  if (!groupsResponse.ok) {
    throw new Error(groupsResponse.errors[0] ?? "No se pudieron obtener las asignaciones.");
  }

  return (
    <>
      <SchoolPageHeader section="Academico" page="Reportes" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Reporte de asistencias"
          description="Prepara reportes de asistencia por materia, estudiante y rango de fechas."
          tone="light"
          returnHref={`/${schoolId}/academico/reportes`}
          returnLabel="Volver a reportes"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[60%_40%]">
          <ReportRunsListPlaceholder
            title="Reportes de asistencias"
            description="Listado de reportes generados para asistencias con su historial de descarga."
            runs={runsResponse.data}
          />

          <AttendanceReportAssignmentPanel schoolId={schoolId} groups={groupsResponse.data} />
        </section>
      </ContentGridSurface>
    </>
  );
}
