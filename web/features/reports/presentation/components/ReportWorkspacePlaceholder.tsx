import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import IndicatorsSummaryCard from "@/features/shared/components/cards/IndicatorsSummaryCard";

type ReportWorkspacePlaceholderProps = {
  summaryTitle: string;
  summaryDescription: string;
  placeholderTitle: string;
  placeholderDescription: string;
};

export default function ReportWorkspacePlaceholder({
  summaryTitle,
  summaryDescription,
  placeholderTitle,
  placeholderDescription,
}: ReportWorkspacePlaceholderProps) {
  return (
    <div className="space-y-5">
      <IndicatorsSummaryCard
        eyebrow="Resumen"
        title={summaryTitle}
        description={summaryDescription}
        items={[
          { label: "Reportes", value: "--", hint: "Sin datos" },
          { label: "Ultima ejecucion", value: "--", hint: "Sin datos" },
        ]}
      />

      <AccentCard variant="softBlue" eyebrow="Implementacion" title={placeholderTitle}>
        <div className="rounded-xl border border-[#c7dbf1] bg-white p-4 text-sm text-[#456a92]">
          {placeholderDescription}
        </div>
      </AccentCard>
    </div>
  );
}
