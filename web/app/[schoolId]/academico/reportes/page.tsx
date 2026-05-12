import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import ReportRunsListPlaceholder from "@/features/reports/presentation/components/ReportRunsListPlaceholder";
import ReportWorkspacePlaceholder from "@/features/reports/presentation/components/ReportWorkspacePlaceholder";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function AcademicoReportesPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  await params;

  return (
    <>
      <SchoolPageHeader section="Academico" page="Reportes" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Reportes academicos"
          description="Configura y genera reportes de asistencia, evaluaciones y promedios para tu institucion."
          tone="light"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[60%_40%]">
          <ReportRunsListPlaceholder
            title="Historial general de reportes"
            description="Concentrado de reportes de asistencias, evaluaciones y promedios."
          />

          <ReportWorkspacePlaceholder
            summaryTitle="Panel de reportes"
            summaryDescription="Resumen general de ejecuciones y actividad de reportes institucionales."
            placeholderTitle="Historial de reportes"
            placeholderDescription="Aqui se mostrara el listado de reportes generados y su descarga directa en siguientes iteraciones."
          />
        </section>
      </ContentGridSurface>
    </>
  );
}
