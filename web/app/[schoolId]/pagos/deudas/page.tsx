import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import { courseApi } from "@/features/academic/data/api/course-api";
import DebtsCourseWorkspace from "@/features/payments/presentation/components/debts/DebtsCourseWorkspace";

export default async function PagosDeudasPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  
  const coursesResponse = await courseApi.getCoursesBySchool(schoolId, 1, 50);
  
  if (!coursesResponse.ok) {
    throw new Error(coursesResponse.errors[0] ?? "No se pudieron obtener los cursos.");
  }

  return (
    <>
      <SchoolPageHeader section="Pagos" page="Deudas de estudiantes" />

      <ContentGridSurface variant="north">
        <PageHeading
          title="Consulta de Deudas"
          description="Selecciona un curso y luego un estudiante para ver su estado de cuenta."
          tone="light"
        />

        <section className="mt-6">
          <DebtsCourseWorkspace schoolId={schoolId} courses={coursesResponse.data.courses} />
        </section>
      </ContentGridSurface>
    </>
  );
}
