import { redirect } from "next/navigation";

import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ScrollArea } from "@/components/ui/scroll-area";
import { paymentConceptRepository } from "@/features/payments/data/repositories/paymentConceptRepository";
import PaymentConceptListItemCard from "@/features/payments/presentation/components/concepts/PaymentConceptListItemCard";
import RegisterPaymentConceptButton from "@/features/payments/presentation/components/concepts/RegisterPaymentConceptButton";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default async function ConceptosDePagoPage({
  params,
}: {
  params: Promise<{ schoolId: string }>;
}) {
  const { schoolId } = await params;

  const response = await paymentConceptRepository.getPaymentConceptsBySchool(schoolId);

  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al obtener los conceptos de pago.");
  }

  const concepts = response.data;
  const activeCount = concepts.length;

  return (
    <>
      <SchoolPageHeader section="Pagos" page="Conceptos de pago" />
      <ContentGridSurface variant="north">
        <PageHeading
          title="Conceptos de pago"
          description="Configura los conceptos de pago para las deudas de los estudiantes."
          tone="light"
        />

        <section className="space-y-4">
          <AccentCard
            variant="softBlue"
            eyebrow="Preparación"
            className="p-4"
          >
            <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
              <RegisterPaymentConceptButton schoolId={schoolId} />

              <div className="grid w-full gap-2 sm:grid-cols-1 lg:max-w-xs">
                <div className="rounded-xl border border-[#c7dbf1] bg-white px-3 py-1.5">
                  <p className="text-[11px] uppercase tracking-[0.14em] text-[#5f82aa]">Conceptos Activos</p>
                  <p className="mt-0.5 text-xl font-semibold text-[#15365a]">{activeCount}</p>
                </div>
              </div>
            </div>
          </AccentCard>

          <AccentCard variant="base" eyebrow="Listado" className="flex h-full flex-col p-6">
            <ScrollArea className="h-[460px] pr-3 mt-4">
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 pb-1">
                {concepts.length ? (
                  concepts.map((concept) => (
                    <PaymentConceptListItemCard
                      key={concept.id}
                      schoolId={schoolId}
                      concept={concept}
                    />
                  ))
                ) : (
                  <div className="col-span-full rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                    No se han registrado conceptos de pago aún.
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
