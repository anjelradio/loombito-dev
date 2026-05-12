import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default function AdministracionBitacoraPage() {
  return (
    <>
      <SchoolPageHeader section="Administracion" page="Bitacora del sistema" />
      <ContentGridSurface variant="north">
        <PageHeading
          title="Bitacora del sistema"
          description="Esta vista se conectara en el siguiente paso con la auditoria global."
          tone="light"
        />
        <AccentCard variant="base" eyebrow="Proximamente" className="p-6">
          <p className="text-sm text-[#46698f]">Configura aqui la consulta global de bitacora del sistema.</p>
        </AccentCard>
      </ContentGridSurface>
    </>
  );
}
