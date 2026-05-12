import Link from "next/link";
import { redirect } from "next/navigation";

import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import AppPagination from "@/features/shared/components/navigation/AppPagination";
import { schoolRepository } from "@/features/school/data/repositories/school.repository";

export default async function AdministracionColegiosPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string }>;
}) {
  const filters = await searchParams;
  const page = Number(filters.page ?? "1");
  const safePage = Number.isNaN(page) ? 1 : page;
  if (safePage < 1) redirect("/administracion/colegios");

  const pageSize = 8;
  const response = await schoolRepository.getSchools(safePage, pageSize);
  if (!response.ok) {
    throw new Error(response.errors[0] ?? "No se pudieron obtener los colegios");
  }

  const data = response.data;
  if (safePage > data.totalPages && data.totalPages > 0) {
    redirect("/administracion/colegios");
  }

  return (
    <>
      <SchoolPageHeader section="Administracion" page="Gestion de colegios" />
      <ContentGridSurface variant="north">
        <PageHeading
          title="Colegios"
          description="Administra los colegios registrados en el sistema y accede a su detalle operativo."
          tone="light"
        />

        <AccentCard variant="base" eyebrow="Listado" className="p-6">
          <div className="space-y-3">
            {data.schools.length ? (
              data.schools.map((school) => (
                <Link
                  key={school.id}
                  href={`/administracion/colegios/${school.id}`}
                  className="block rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 transition-colors hover:bg-[#eef5ff]"
                >
                  <p className="text-base font-semibold text-[#1f4d7d]">{school.name}</p>
                  <p className="mt-1 text-sm text-[#52749a]">
                    Tipo: {school.type} · Telefono: {school.phone}
                  </p>
                </Link>
              ))
            ) : (
              <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                No hay colegios registrados.
              </div>
            )}
          </div>

          <AppPagination
            page={data.page}
            totalPages={data.totalPages}
            basePath="/administracion/colegios"
            hasPrev={data.hasPrev}
            hasNext={data.hasNext}
          />
        </AccentCard>
      </ContentGridSurface>
    </>
  );
}
