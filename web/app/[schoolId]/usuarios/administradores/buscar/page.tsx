import PageHeading from "@/components/shared/PageHeading";
import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import { schoolMembersRepository } from "@/features/school/data/repositories";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ScrollArea } from "@/components/ui/scroll-area";
import UserListItemCard from "@/features/school/presentation/components/users/UserListItemCard";
import UsersSearchRedirectForm from "@/features/school/presentation/components/users/UsersSearchRedirectForm";

export default async function BuscarAdministradoresPage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string }>;
  searchParams: Promise<{ name?: string }>;
}) {
  const { schoolId } = await params;
  const filters = await searchParams;
  const query = (filters.name ?? "").trim();

  const response = await schoolMembersRepository.getUsersBySchool(
    schoolId,
    "admin",
    1,
    50,
    query,
  );
  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al buscar administradores.");
  }

  const users = response.data.users;
  const searchPath = `/${schoolId}/usuarios/administradores/buscar`;

  return (
    <>
      <SchoolPageHeader section="Usuarios" page="Buscar administradores" />

      <ContentGridSurface variant="north">
        <PageHeading
          title="Buscar administradores"
          description="Encuentra personal administrativo por nombre dentro de esta escuela."
          tone="light"
          returnHref={`/${schoolId}/usuarios/administradores`}
        />

        <section>
          <AccentCard
            variant="base"
            eyebrow="Listado"
            className="flex h-full flex-col p-6"
          >
            <UsersSearchRedirectForm basePath={searchPath} query={query} />

            <ScrollArea className="h-[400px] pr-3">
              <div className="space-y-3 pb-1">
                {users.length ? (
                  users.map((item) => (
                    <UserListItemCard
                      key={item.id}
                      schoolId={schoolId}
                      item={item}
                      label="Administrador"
                    />
                  ))
                ) : (
                  <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                    No hay resultados para la busqueda actual.
                  </div>
                )}
              </div>
            </ScrollArea>
          </AccentCard>
        </section>
      </ContentGridSurface>
    </>
  );
}
