import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import type { ReportRun } from "@/features/reports/domain/entities/report";

type ReportRunsListPlaceholderProps = {
  title: string;
  description?: string;
  runs?: ReportRun[];
};

export default function ReportRunsListPlaceholder({
  title,
  description,
  runs = [],
}: ReportRunsListPlaceholderProps) {
  const formatDate = (value: string) =>
    new Intl.DateTimeFormat("es-BO", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(new Date(value));

  return (
    <AccentCard variant="base" eyebrow="Listado" title={title} description={description} className="p-5">
      <div className="space-y-3 rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-3.5">
        {runs.length ? (
          <div className="space-y-2">
            {runs.map((run) => (
              <div key={run.id} className="rounded-lg border border-[#dbe9f8] bg-white p-3 text-sm text-[#52749a]">
                <p className="font-semibold text-[#1f4d7d]">{run.summary || "Reporte sin descripcion"}</p>
                <p className="mt-1 text-xs text-[#5d80a7]">{formatDate(run.createdDate)}</p>
              </div>
            ))}
          </div>
        ) : (
          <div className="rounded-lg border border-[#dbe9f8] bg-white p-3 text-sm text-[#52749a]">
            Aun no hay reportes generados para este tipo.
          </div>
        )}
        <div className="rounded-lg border border-dashed border-[#c7dbf1] bg-white p-3 text-xs text-[#6a8cb2]">
          En esta seccion se mostrara el historial de reportes con fecha, descripcion y descarga.
        </div>
      </div>
    </AccentCard>
  );
}
