import PaymentConceptEditButton from "./PaymentConceptEditButton";
import PaymentConceptDeleteButton from "./PaymentConceptDeleteButton";
import type { PaymentConcept } from "@/features/payments/domain/entities/payment-concept";

type PaymentConceptListItemCardProps = {
  schoolId: string;
  concept: PaymentConcept;
};

export default function PaymentConceptListItemCard({
  schoolId,
  concept,
}: PaymentConceptListItemCardProps) {
  return (
    <article className="group flex min-h-40 flex-col justify-between rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 shadow-[0_16px_32px_-28px_rgba(10,31,61,0.5)] transition-all duration-200 hover:-translate-y-0.5 hover:shadow-[0_22px_38px_-30px_rgba(10,31,61,0.55)]">
      <div className="flex min-w-0 flex-col items-start gap-3">
        <div className="flex w-full items-start justify-between">
          <div className="min-w-0 flex-1">
            <p className="text-[11px] uppercase tracking-[0.14em] text-[#6a8cb2]">
              {concept.is_recurring ? "Recurrente" : "Pago único"}
            </p>
            <p className="mt-1 truncate text-lg font-semibold text-[#1f4d7d]">{concept.name}</p>
          </div>
          <div className="rounded-lg bg-[#e8f1fc] px-3 py-1.5 text-right">
            <p className="text-sm font-bold text-[#2b5f97]">Bs. {concept.amount.toFixed(2)}</p>
          </div>
        </div>
      </div>

      <div className="mt-4 flex items-center justify-end gap-2 border-t border-[#d5e3f3] pt-3">
        <PaymentConceptEditButton schoolId={schoolId} concept={concept} />
        <PaymentConceptDeleteButton
          schoolId={schoolId}
          conceptId={concept.id}
          conceptName={concept.name}
        />
      </div>
    </article>
  );
}
