import { redirect } from "next/navigation";

import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ScrollArea } from "@/components/ui/scroll-area";
import { subjectRepository } from "@/features/academic/data/repositories";
import SubjectCreateForm from "@/features/academic/presentation/components/subject/SubjectCreateForm";
import SubjectListItemCard from "@/features/academic/presentation/components/subject/SubjectListItemCard";
import SubjectSearchForm from "@/features/academic/presentation/components/subject/SubjectSearchForm";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import IndicatorsSummaryCard from "@/features/shared/components/cards/IndicatorsSummaryCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import AppPagination from "@/features/shared/components/navigation/AppPagination";

export default async function MateriasPage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string }>;
  searchParams: Promise<{ page?: string; search?: string }>;
}) {
  const { schoolId } = await params;
  const filters = await searchParams;

  const page = Number(filters.page ?? "1");
  const safePage = Number.isNaN(page) ? 1 : page;
  const search = (filters.search ?? "").trim();

  if (safePage < 1) {
    redirect(`/${schoolId}/academico/materias`);
  }

  const pageSize = 9;
  const response = await subjectRepository.getSubjectsBySchool(
    schoolId,
    safePage,
    pageSize,
    search,
  );

  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al obtener las materias.");
  }

  const data = response.data;
  if (safePage > data.totalPages && data.totalPages > 0) {
    redirect(`/${schoolId}/academico/materias`);
  }

  return (
    <>
      <SchoolPageHeader section="Academico" page="Materias" />

      <ContentGridSurface variant="mist">
        <PageHeading
          title="Materias"
          description="Registra y consulta las materias activas de tu escuela para luego vincularlas a cursos y asignaciones docentes."
          tone="light"
        />

        <section className="grid items-stretch gap-4 2xl:grid-cols-[70%_30%]">
          <AccentCard
            variant="base"
            eyebrow="Listado"
            className="flex h-full flex-col p-6"
          >
            <SubjectSearchForm
              basePath={`/${schoolId}/academico/materias`}
              defaultSearch={search}
            />

            <ScrollArea className="h-[430px] pr-3">
              <div className="grid grid-cols-1 gap-3 pb-1 sm:grid-cols-2 xl:grid-cols-3">
                {data.subjects.length ? (
                  data.subjects.map((subject) => (
                    <SubjectListItemCard
                      key={subject.id}
                      schoolId={schoolId}
                      subject={subject}
                    />
                  ))
                ) : (
                  <div className="col-span-full rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                    No hay materias registradas para los filtros seleccionados.
                  </div>
                )}
              </div>
            </ScrollArea>

            <AppPagination
              page={data.page}
              totalPages={data.totalPages}
              basePath={`/${schoolId}/academico/materias`}
              hasPrev={data.hasPrev}
              hasNext={data.hasNext}
              query={{ search }}
            />
          </AccentCard>

          <div className="flex min-w-0 flex-col gap-4">
            <AccentCard
              variant="softBlue"
              eyebrow="Registro"
              title="Registrar nueva materia"
              description="Crea materias para que luego puedan asociarse a los cursos de la institucion."
              className="w-full"
            >
              <SubjectCreateForm schoolId={schoolId} />
            </AccentCard>

            <IndicatorsSummaryCard
              eyebrow="Indicadores"
              title="Resumen de materias"
              description="Estos indicadores se conectaran con metricas reales en una siguiente iteracion."
              items={[
                { label: "Activas", value: "--" },
                { label: "Inactivas", value: "--" },
              ]}
              className="w-full"
            />
          </div>
        </section>
      </ContentGridSurface>
    </>
  );
}
