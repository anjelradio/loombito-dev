import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import { schoolBackupRepository } from "@/features/system/data/repositories";
import SchoolBackupsListCard from "@/features/system/presentation/components/SchoolBackupsListCard";

export default async function SchoolBackupPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const response = await schoolBackupRepository.getSchoolBackups(schoolId);

  if (!response.ok) {
    throw new Error(response.errors[0] ?? "No se pudo obtener copias de seguridad.");
  }

  return (
    <>
      <SchoolPageHeader section="Sistema" page="Copia de seguridad" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Copias de seguridad"
          description="Gestiona respaldos manuales de tu escuela para recuperacion de datos."
          tone="light"
        />

        <section className="grid items-start gap-5 xl:grid-cols-[60%_40%]">
          <SchoolBackupsListCard schoolId={schoolId} backups={response.data} />

          <div className="space-y-5">
            <AccentCard
              variant="base"
              eyebrow="Resumen"
              title="Respaldo"
              description="En esta area veras metricas y estado general de las copias de seguridad."
              className="p-5"
            >
              <div className="rounded-lg border border-[#dbe9f8] bg-[#f8fbff] p-3 text-sm text-[#52749a]">
                Sin datos por ahora.
              </div>
            </AccentCard>

            <AccentCard
              variant="softBlue"
              eyebrow="Implementacion"
              title="Proximamente"
              description="Aqui se habilitaran acciones de restaurar, eliminar y descargar copias de seguridad."
              className="p-5"
            />
          </div>
        </section>
      </ContentGridSurface>
    </>
  );
}
