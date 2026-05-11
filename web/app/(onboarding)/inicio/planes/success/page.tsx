import Link from "next/link";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { subscriptionRepository } from "@/features/subscriptions/data/repositories/subscription.repository";

export default async function PlansSuccessPage({
  searchParams,
}: {
  searchParams: Promise<{ schoolId?: string; session_id?: string }>;
}) {
  const { schoolId, session_id: sessionId } = await searchParams;
  const syncResult = sessionId
    ? await subscriptionRepository.syncCheckoutSession(sessionId)
    : null;

  return (
    <div className="flex flex-1 items-center justify-center px-4 py-10">
      <Card className="w-full max-w-2xl rounded-3xl border-none bg-white shadow-[0_28px_60px_-28px_rgba(10,31,61,0.55)]">
        <CardHeader className="space-y-3 border-b border-slate-200/80 pb-6 pt-8">
          <CardTitle className="text-center text-3xl font-semibold text-[#1E3A5F]">
            Pago recibido
          </CardTitle>
          <CardDescription className="mx-auto max-w-xl text-center text-base leading-relaxed text-slate-600">
            Stripe confirmo el proceso de pago. El plan se actualiza cuando el webhook del
            backend termina la validacion.
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-5 px-6 pb-8 pt-6 text-center sm:px-8">
          {syncResult ? (
            syncResult.ok ? (
              <div className="rounded-xl border border-[#c8e6d0] bg-[#f5fff7] px-4 py-3 text-sm text-[#23613a]">
                Plan actualizado a {syncResult.data.planName}.
              </div>
            ) : (
              <div className="rounded-xl border border-[#f0caca] bg-[#fff8f8] px-4 py-3 text-sm text-[#9b3f3f]">
                {syncResult.errors[0] ?? "No se pudo actualizar el plan automaticamente."}
              </div>
            )
          ) : null}

          {sessionId ? (
            <p className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] px-4 py-3 text-xs text-[#52749a]">
              Sesion de pago: {sessionId}
            </p>
          ) : null}

          <div className="flex flex-col justify-center gap-3 sm:flex-row">
            {schoolId ? (
              <>
                <Link
                  href={`/${schoolId}/suscripciones/actual`}
                  className="inline-flex h-11 items-center justify-center rounded-lg bg-[#1E3A5F] px-5 text-sm font-semibold text-white hover:bg-[#152B47]"
                >
                  Ver plan actual
                </Link>
                <Link
                  href={`/${schoolId}/inicio`}
                  className="inline-flex h-11 items-center justify-center rounded-lg border border-[#c7dbf1] bg-white px-5 text-sm font-semibold text-[#1E3A5F] hover:bg-[#f4f8fd]"
                >
                  Ir al dashboard
                </Link>
              </>
            ) : (
              <Link
                href="/inicio"
                className="inline-flex h-11 items-center justify-center rounded-lg bg-[#1E3A5F] px-5 text-sm font-semibold text-white hover:bg-[#152B47]"
              >
                Volver a inicio
              </Link>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
