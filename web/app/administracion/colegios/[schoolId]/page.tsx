import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function AdministracionColegioDetallePage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;

  return (
    <>
      <SchoolPageHeader section="Administracion" page="Detalle de colegio" />
      <ContentGridSurface variant="north">
        <PageHeading
          title="Detalle de colegio"
          description={`Colegio seleccionado: ${schoolId}`}
          tone="light"
        />

        <AccentCard variant="base" eyebrow="Proximamente" className="p-6">
          <p className="text-sm text-[#46698f]">
            Aqui se mostraran acciones administrativas y accesos directos, incluyendo bitacora del colegio.
          </p>
        </AccentCard>
      </ContentGridSurface>
    </>
  );
}
