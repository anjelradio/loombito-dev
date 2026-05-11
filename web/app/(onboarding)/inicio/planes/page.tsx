import Link from "next/link";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { schoolRepository } from "@/features/school/data/repositories/school.repository";
import SubscriptionPlanCard from "@/features/subscriptions/presentation/components/SubscriptionPlanCard";
import { SUBSCRIPTION_PLAN_CATALOG } from "@/features/subscriptions/presentation/config/plan-catalog";

export default async function PlansCatalogPage({
  searchParams,
}: {
  searchParams: Promise<{ schoolId?: string; canceled?: string }>;
}) {
  const { schoolId, canceled } = await searchParams;
  const schoolsResponse = await schoolRepository.getSchoolsByUser();

  const schools = schoolsResponse.ok ? schoolsResponse.data : [];
  const selectedSchool = schoolId ? schools.find((school) => school.id === schoolId) : null;
  const canManagePlans = selectedSchool?.role === "owner";

  return (
    <div className="flex flex-1 items-center px-0 py-8 md:px-4 md:py-10 lg:px-6">
      <Card className="mx-4 w-[calc(100%-2rem)] max-w-[1200px] rounded-3xl border-none bg-white shadow-[0_28px_60px_-28px_rgba(10,31,61,0.55)] md:mx-auto md:w-full">
        <CardHeader className="space-y-3 border-b border-slate-200/80 pb-6 pt-8">
          <CardTitle className="text-center text-3xl font-semibold text-[#1E3A5F] sm:text-4xl">
            {selectedSchool ? `Planes para ${selectedSchool.name}` : "Catalogo de planes"}
          </CardTitle>
          <CardDescription className="mx-auto max-w-3xl text-center text-base leading-relaxed text-slate-600">
            Elige el plan que mejor acompane el crecimiento academico de tu institucion. Podras
            completar el pago de forma segura con Stripe y volver al sistema cuando finalice.
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6 px-6 pb-8 pt-6 sm:px-8 md:px-10">
          {canceled ? (
            <div className="rounded-xl border border-[#f1d1a5] bg-[#fff9ef] p-4 text-sm text-[#8a5a16]">
              El pago fue cancelado. Puedes elegir otro plan o volver al dashboard de tu escuela.
            </div>
          ) : null}

          {!canManagePlans ? (
            <div className="rounded-xl border border-[#f0caca] bg-[#fff8f8] p-4 text-sm text-[#9b3f3f]">
              No encontramos una escuela valida donde tengas rol de director para gestionar
              suscripciones.
              <div className="mt-3">
                <Link
                  href="/inicio"
                  className="inline-flex rounded-md bg-[#1E3A5F] px-3 py-2 text-xs font-semibold text-white hover:bg-[#152B47]"
                >
                  Volver a inicio
                </Link>
              </div>
            </div>
          ) : null}

          <section className="grid gap-4 lg:grid-cols-3">
            {SUBSCRIPTION_PLAN_CATALOG.map((plan) => (
              <SubscriptionPlanCard
                key={plan.code}
                plan={plan}
                schoolId={canManagePlans ? selectedSchool.id : undefined}
              />
            ))}
          </section>
        </CardContent>
      </Card>
    </div>
  );
}
