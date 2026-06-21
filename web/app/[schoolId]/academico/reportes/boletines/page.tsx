import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import { courseApi } from "@/features/academic/data/api/course-api";
import BoletinesCourseWorkspace from "@/features/reports/presentation/components/BoletinesCourseWorkspace";

export default async function AcademicoReportesBoletinesPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  
  // Hacemos fetch de todos los cursos. Traemos perPage = 50 por ahora para abarcarlos.
  const coursesResponse = await courseApi.getCoursesBySchool(schoolId, 1, 50);
  
  if (!coursesResponse.ok) {
    throw new Error(coursesResponse.errors[0] ?? "No se pudieron obtener los cursos.");
  }

  return (
    <>
      <SchoolPageHeader section="Academico" page="Reportes" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Generación de Boletines"
          description="Selecciona un curso para ver a los estudiantes y generar sus boletines académicos."
          tone="light"
          returnHref={`/${schoolId}/academico/reportes`}
          returnLabel="Volver a reportes"
        />

        <section className="mt-6">
          <BoletinesCourseWorkspace schoolId={schoolId} courses={coursesResponse.data.courses} />
        </section>
      </ContentGridSurface>
    </>
  );
}
