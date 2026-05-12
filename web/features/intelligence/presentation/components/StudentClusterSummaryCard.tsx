import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import type { StudentClusterSnapshot } from "@/features/intelligence/domain/entities/student-cluster";

type StudentClusterSummaryCardProps = {
  snapshot: StudentClusterSnapshot;
  selectedTermName: string;
};

export default function StudentClusterSummaryCard({
  snapshot,
  selectedTermName,
}: StudentClusterSummaryCardProps) {
  const total = snapshot.students.length;
  const high = snapshot.students.filter((item) => item.clusterLabel === "alto_rendimiento").length;
  const medium = snapshot.students.filter((item) => item.clusterLabel === "rendimiento_medio").length;
  const risk = snapshot.students.filter((item) => item.clusterLabel === "en_riesgo").length;

  return (
    <AccentCard variant="base" eyebrow="Resumen" title="Clasificacion del trimestre">
      <div className="space-y-3 rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-3">
        <div className="flex items-center justify-between text-sm text-[#315a85]"><span className="font-medium">Trimestre</span><span>{selectedTermName}</span></div>
        <div className="flex items-center justify-between text-sm text-[#315a85]"><span className="font-medium">Estudiantes</span><span>{total}</span></div>
        <div className="flex items-center justify-between text-sm text-[#315a85]"><span className="font-medium">Alto rendimiento</span><span>{high}</span></div>
        <div className="flex items-center justify-between text-sm text-[#315a85]"><span className="font-medium">Rendimiento medio</span><span>{medium}</span></div>
        <div className="flex items-center justify-between text-sm text-[#315a85]"><span className="font-medium">En riesgo</span><span>{risk}</span></div>
        <div className="flex items-center justify-between text-sm text-[#315a85]"><span className="font-medium">k</span><span>{snapshot.kValue ?? "--"}</span></div>
      </div>
    </AccentCard>
  );
}
