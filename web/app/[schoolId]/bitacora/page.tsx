import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import AppPagination from "@/features/shared/components/navigation/AppPagination";
import { auditRepository } from "@/features/system/data/repositories";
import AuditAccessCard from "@/features/system/presentation/components/AuditAccessCard";
import SchoolAuditLogsTable from "@/features/system/presentation/components/SchoolAuditLogsTable";
import { redirect } from "next/navigation";

export default async function SchoolAuditPage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string }>;
  searchParams: Promise<{ page?: string }>;
}) {
  const { schoolId } = await params;
  const filters = await searchParams;
  const page = Number(filters.page ?? "1");
  const safePage = Number.isNaN(page) ? 1 : page;

  if (safePage < 1) redirect(`/${schoolId}/bitacora`);

  const pageSize = 12;
  const response = await auditRepository.getSchoolAuditLogs(schoolId, safePage, pageSize);

  const needsAccessKey =
    !response.ok &&
    response.errors.some((error) =>
      error.toLowerCase().includes("llave") || error.toLowerCase().includes("bitacora"),
    );

  const basePath = `/${schoolId}/bitacora`;

  return (
    <>
      <SchoolPageHeader section="Sistema" page="Bitacora" />

      <ContentGridSurface variant="north">
        <PageHeading
          title="Bitacora"
          description="Consulta el historial de acciones registradas en esta escuela."
          tone="light"
        />

        <AccentCard variant="base" eyebrow="Registros" className="p-6">
          {needsAccessKey ? <AuditAccessCard /> : null}

          {!response.ok && !needsAccessKey ? (
            <div className="rounded-xl border border-[#f0c9c9] bg-[#fff1f1] p-4 text-sm text-[#a64646]">
              {response.errors[0] ?? "No se pudo obtener la bitacora."}
            </div>
          ) : null}

          {response.ok ? (
            <>
              <SchoolAuditLogsTable rows={response.data.logs} />
              <AppPagination
                page={response.data.page}
                totalPages={response.data.totalPages}
                basePath={basePath}
                hasPrev={response.data.hasPrev}
                hasNext={response.data.hasNext}
              />
            </>
          ) : null}
        </AccentCard>
      </ContentGridSurface>
    </>
  );
}
