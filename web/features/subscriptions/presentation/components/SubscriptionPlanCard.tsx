"use client";

import Link from "next/link";
import { useTransition } from "react";

import { createCheckoutSession } from "@/features/subscriptions/presentation/actions/create-checkout-session-action";
import type { SubscriptionPlan } from "@/features/subscriptions/domain/entities/plan";
import { appToast } from "@/features/shared/components/toast/toast";

type SubscriptionPlanCardProps = {
  plan: SubscriptionPlan;
  schoolId?: string;
};

export default function SubscriptionPlanCard({ plan, schoolId }: SubscriptionPlanCardProps) {
  const [isPending, startTransition] = useTransition();
  const freeHref = schoolId && plan.code === "free" ? `/${schoolId}/inicio` : null;

  const handlePaidPlan = () => {
    if (!schoolId) {
      appToast.error("Selecciona una escuela valida antes de elegir un plan.");
      return;
    }

    if (plan.code === "free") {
      return;
    }

    const planCode = plan.code;
    startTransition(async () => {
      const response = await createCheckoutSession(schoolId, planCode);
      if (!response.ok) {
        appToast.error(response.errors[0] ?? "No se pudo iniciar el pago.");
        return;
      }

      window.location.assign(response.data.checkoutUrl);
    });
  };

  return (
    <article
      className={`relative overflow-hidden rounded-2xl border p-5 shadow-[0_20px_40px_-30px_rgba(10,31,61,0.65)] ${
        plan.featured
          ? "border-[#8fb4df] bg-[radial-gradient(120%_120%_at_0%_0%,#ffffff_0%,#f2f8ff_52%,#e7f1ff_100%)]"
          : "border-[#d5e3f3] bg-white"
      }`}
    >
      {plan.featured ? (
        <span className="absolute right-4 top-4 rounded-full bg-[#1E3A5F] px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.12em] text-white">
          Recomendado
        </span>
      ) : null}

      <div className="space-y-2">
        <p className="text-xs uppercase tracking-[0.14em] text-[#6a8cb2]">Plan</p>
        <h3 className="text-2xl font-semibold text-[#1f4d7d]">{plan.name}</h3>
        <p className="text-sm leading-relaxed text-[#52749a]">{plan.description}</p>
      </div>

      <div className="mt-4 rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-3">
        <p className="text-2xl font-semibold text-[#1f4d7d]">{plan.priceLabel}</p>
        <p className="text-xs uppercase tracking-[0.12em] text-[#6a8cb2]">{plan.billingLabel}</p>
      </div>

      <div className="mt-4 space-y-2.5">
        <p className="text-xs font-semibold uppercase tracking-[0.12em] text-[#4d7098]">Incluye</p>
        <ul className="space-y-1.5 text-sm text-[#315a85]">
          {plan.highlights.map((item) => (
            <li key={item} className="flex gap-2">
              <span className="mt-1 h-1.5 w-1.5 rounded-full bg-[#3f78b4]" />
              <span>{item}</span>
            </li>
          ))}
        </ul>
      </div>

      {plan.limitations?.length ? (
        <div className="mt-4 space-y-2.5">
          <p className="text-xs font-semibold uppercase tracking-[0.12em] text-[#7f95ae]">Limitaciones</p>
          <ul className="space-y-1.5 text-sm text-[#607f9f]">
            {plan.limitations.map((item) => (
              <li key={item} className="flex gap-2">
                <span className="mt-1 h-1.5 w-1.5 rounded-full bg-[#9db4cb]" />
                <span>{item}</span>
              </li>
            ))}
          </ul>
        </div>
      ) : null}

      {freeHref ? (
        <Link
          href={freeHref}
          className="mt-5 inline-flex h-10 w-full items-center justify-center rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white hover:bg-[#152B47]"
        >
          Empezar gratis
        </Link>
      ) : schoolId && plan.code !== "free" ? (
        <button
          type="button"
          disabled={isPending}
          onClick={handlePaidPlan}
          className="mt-5 inline-flex h-10 w-full items-center justify-center rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white hover:bg-[#152B47] disabled:cursor-not-allowed disabled:opacity-70"
        >
          {isPending ? "Redirigiendo..." : "Elegir plan"}
        </button>
      ) : (
        <button
          type="button"
          disabled
          className="mt-5 inline-flex h-10 w-full items-center justify-center rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white opacity-60"
        >
          Seleccion no disponible
        </button>
      )}
    </article>
  );
}
