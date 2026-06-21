"use client";

import { StudentDebt } from "@/features/payments/domain/entities/student-debt";
import { StudentPayment } from "@/features/payments/domain/entities/student-payment";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import StudentDebtCard from "./StudentDebtCard";

interface Props {
  debts: StudentDebt[];
  payments: StudentPayment[];
}

export default function StudentDebtsList({ debts, payments }: Props) {
  const totalAmount = debts.reduce((sum, debt) => sum + debt.amount, 0);
  const totalPaid = payments.reduce((sum, payment) => sum + payment.amount_paid, 0);

  return (
    <div className="space-y-6">
      {/* Summary Card */}
      <AccentCard variant="softBlue" className="p-5 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-semibold text-[#15365a]">Resumen de Cuenta</h3>
          <p className="text-sm text-[#5f82aa]">Tienes {debts.length} concepto(s) pendiente(s) de pago.</p>
        </div>
        <div className="flex flex-wrap gap-4">
          <div className="rounded-xl border border-[#c7dbf1] bg-white px-5 py-3 shadow-sm text-right">
            <p className="text-[11px] uppercase tracking-[0.14em] text-[#5f82aa]">Total Pagado</p>
            <p className="mt-0.5 text-2xl font-bold text-[#1f6e45]">Bs. {totalPaid.toFixed(2)}</p>
          </div>
          <div className="rounded-xl border border-[#c7dbf1] bg-white px-5 py-3 shadow-sm text-right">
            <p className="text-[11px] uppercase tracking-[0.14em] text-[#5f82aa]">Deuda Total</p>
            <p className="mt-0.5 text-2xl font-bold text-[#b84f4f]">Bs. {totalAmount.toFixed(2)}</p>
          </div>
        </div>
      </AccentCard>

      {/* List */}
      <AccentCard variant="base" eyebrow="Listado de Deudas" className="p-6">
        {debts.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {debts.map((debt) => (
              <StudentDebtCard key={debt.id} debt={debt} />
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-[#c7dbf1] bg-[#f8fbff] p-10 text-center">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#e8f1fc] text-[#52749a] mb-3">
              <span className="text-2xl">🎉</span>
            </div>
            <p className="text-base font-medium text-[#15365a]">¡Al día!</p>
            <p className="mt-1 text-sm text-[#52749a]">El estudiante no tiene ninguna deuda pendiente registrada.</p>
          </div>
        )}
      </AccentCard>
    </div>
  );
}
