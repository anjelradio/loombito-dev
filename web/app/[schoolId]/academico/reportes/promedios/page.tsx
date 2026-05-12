import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { reportRepository } from "@/features/reports/data/repositories/report.repository";
import ReportRunsListPlaceholder from "@/features/reports/presentation/components/ReportRunsListPlaceholder";
import ReportWorkspacePlaceholder from "@/features/reports/presentation/components/ReportWorkspacePlaceholder";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function AcademicoReportesPromediosPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const runsResponse = await reportRepository.getRunsBySchool(schoolId, "term_average_report");
  if (!runsResponse.ok) {
    throw new Error(runsResponse.errors[0] ?? "No se pudieron obtener reportes de promedios.");
  }

  return (
    <>
      <SchoolPageHeader section="Academico" page="Reportes" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Reporte de promedios"
          description="Prepara reportes de promedios trimestrales por materia y por estudiante."
          tone="light"
          returnHref={`/${schoolId}/academico/reportes`}
          returnLabel="Volver a reportes"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[60%_40%]">
          <ReportRunsListPlaceholder
            title="Reportes de promedios"
            description="Listado de reportes trimestrales generados por materia y estudiante."
            runs={runsResponse.data}
          />

          <ReportWorkspacePlaceholder
            summaryTitle="Promedios trimestrales"
            summaryDescription="Esta vista mostrara filtros por trimestre y materia, con detalle exportable por estudiante."
            placeholderTitle="Configuracion pendiente"
            placeholderDescription="En la siguiente etapa se habilitara seleccion de trimestre, columnas y descarga en Excel/PDF."
          />
        </section>
      </ContentGridSurface>
    </>
  );
}
