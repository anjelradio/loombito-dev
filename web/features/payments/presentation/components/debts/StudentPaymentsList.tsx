"use client";

import { StudentPayment } from "@/features/payments/domain/entities/student-payment";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";

// Props del componente de historial de transacciones
interface Props {
  payments: StudentPayment[];
}

// Renderiza una tabla con el historial de pagos del estudiante
export default function StudentPaymentsList({ payments }: Props) {
  if (payments.length === 0) return null;

  return (
    <AccentCard variant="base" eyebrow="Listado de Transacciones" className="p-6 mt-6">
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm text-[#52749a]">
          <thead className="bg-[#f8fbff] text-[#15365a] uppercase text-xs">
            <tr>
              <th className="px-4 py-3 rounded-tl-lg">Fecha</th>
              <th className="px-4 py-3">Concepto</th>
              <th className="px-4 py-3 rounded-tr-lg text-right">Monto Pagado</th>
            </tr>
          </thead>
          <tbody>
            {payments.map((payment) => (
              <tr key={payment.id} className="border-b border-[#e4ebf4] last:border-0 hover:bg-[#fcfdfd] transition-colors">
                <td className="px-4 py-4 font-medium text-[#15365a]">
                  {new Date(payment.payment_date).toLocaleDateString("es-ES", {
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                    hour: "2-digit",
                    minute: "2-digit"
                  })}
                </td>
                <td className="px-4 py-4">{payment.concept_name}</td>
                <td className="px-4 py-4 text-right font-bold text-[#1f6e45]">
                  Bs. {payment.amount_paid.toFixed(2)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AccentCard>
  );
}
