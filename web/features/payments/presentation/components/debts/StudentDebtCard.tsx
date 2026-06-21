"use client";

import { StudentDebt } from "@/features/payments/domain/entities/student-debt";
import { AlertCircle, Calendar } from "lucide-react";

interface Props {
  debt: StudentDebt;
}

export default function StudentDebtCard({ debt }: Props) {
  const isPending = debt.status === "PENDING";
  
  // Format month to name
  const monthNames = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
  const periodText = debt.billing_month && debt.billing_year 
    ? `${monthNames[debt.billing_month - 1]} ${debt.billing_year}`
    : "Pago Único";

  return (
    <article className="group flex flex-col justify-between rounded-xl border border-[#f2c8c8] bg-[#fff5f5] p-5 shadow-[0_12px_24px_-20px_rgba(184,79,79,0.3)] transition-all duration-200 hover:-translate-y-0.5 hover:shadow-[0_16px_32px_-20px_rgba(184,79,79,0.4)]">
      <div className="flex items-start justify-between gap-4">
        <div className="min-w-0">
          <p className="text-xs font-bold uppercase tracking-[0.14em] text-[#b84f4f]">
            Pendiente
          </p>
          <p className="mt-1.5 truncate text-[17px] font-bold text-[#7d1f1f]">{debt.concept_name}</p>
        </div>
        <div className="shrink-0 rounded-lg bg-white px-3 py-1.5 shadow-sm border border-[#f2c8c8]">
          <p className="text-[15px] font-black text-[#b84f4f]">Bs. {debt.amount.toFixed(2)}</p>
        </div>
      </div>

      <div className="mt-4 flex items-center gap-2 rounded-lg bg-white/60 p-2.5 text-xs font-medium text-[#7d1f1f]">
        <Calendar className="h-4 w-4 shrink-0 text-[#b84f4f]" />
        <span>{periodText}</span>
      </div>
    </article>
  );
}
