import InvitationGenerateCards from "@/features/school/presentation/components/invitation/InvitationGenerateCards";
import PageHeading from "@/components/shared/PageHeading";
import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import { invitationRepository } from "@/features/school/data/repositories/invitation.repository";
import InvitationCodesTable from "@/features/school/presentation/components/invitation/InvitationCodesTable";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function InvitationUsersPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;
  const response = await invitationRepository.getSchoolInvitations(schoolId);
  const invitations =
    response.ok && "data" in response && response.data ? response.data : [];

  return (
    <>
      <SchoolPageHeader section="Usuarios" page="Invitaciones" />

      <ContentGridSurface variant="north">
        <PageHeading
          title="Invitaciones"
          description="Crea y gestiona codigos de invitacion para personal administrativo y profesores. Cada codigo se genera segun el tipo de rol de destino."
          tone="light"
          titleClassName="text-3xl"
          descriptionClassName="max-w-3xl"
        />

        <section className="grid gap-4 xl:grid-cols-[40%_60%]">
          <div className="space-y-4">
            <InvitationGenerateCards schoolId={schoolId} />
          </div>

          <AccentCard
            variant="base"
            eyebrow="Historial"
            title="Codigos activos"
            description="Administra y monitorea los codigos generados para personal administrativo y docentes."
            className="p-6"
          >
            <InvitationCodesTable schoolId={schoolId} items={invitations} />
          </AccentCard>
        </section>
      </ContentGridSurface>
    </>
  );
}
