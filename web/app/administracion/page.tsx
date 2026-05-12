import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default function AdministracionDashboardPage() {
  return (
    <>
      <SchoolPageHeader section="Administracion" page="Dashboard" />
      <ContentGridSurface variant="north">
        <PageHeading
          title="Panel de administracion"
          description="Gestiona los modulos globales del sistema y supervisa los colegios registrados."
          tone="light"
        />

        <AccentCard variant="base" eyebrow="Proximamente" className="p-6">
          <p className="text-sm text-[#46698f]">
            Este panel principal se ira completando con indicadores del sistema.
          </p>
        </AccentCard>
      </ContentGridSurface>
    </>
  );
}
