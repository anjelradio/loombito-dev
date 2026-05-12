import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import type { StudentClusterRow } from "@/features/intelligence/domain/entities/student-cluster";

type StudentClusterListProps = {
  rows: StudentClusterRow[];
};

const LABEL_STYLES: Record<StudentClusterRow["clusterLabel"], string> = {
  alto_rendimiento: "bg-emerald-100 text-emerald-700 border-emerald-200",
  rendimiento_medio: "bg-sky-100 text-sky-700 border-sky-200",
  en_riesgo: "bg-rose-100 text-rose-700 border-rose-200",
};

export default function StudentClusterList({ rows }: StudentClusterListProps) {
  if (!rows.length) {
    return (
      <div className="flex h-[500px] items-center rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
        <p>No hay clasificaciones aun para este trimestre.</p>
      </div>
    );
  }

  return (
    <div className="h-[500px] overflow-y-auto rounded-xl border border-[#d5e3f3] bg-[#f8fbff]">
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead className="sticky top-0 z-10 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">Apellido</TableHead>
            <TableHead className="sticky top-0 z-10 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">Nombre</TableHead>
            <TableHead className="sticky top-0 z-10 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">Grupo</TableHead>
            <TableHead className="sticky top-0 z-10 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">Promedio</TableHead>
            <TableHead className="sticky top-0 z-10 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">Asistencia</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rows.map((row) => (
            <TableRow key={row.studentId} className="border-[#dbe9f8] hover:bg-[#f1f7ff]">
              <TableCell className="font-medium text-[#234f7e]">{row.lastName}</TableCell>
              <TableCell className="text-[#315a85]">{row.firstName}</TableCell>
              <TableCell>
                <span className={`rounded-full border px-2.5 py-1 text-xs font-semibold ${LABEL_STYLES[row.clusterLabel]}`}>
                  {row.clusterLabel.replaceAll("_", " ")}
                </span>
              </TableCell>
              <TableCell className="text-[#315a85]">{row.finalScore.toFixed(2)}</TableCell>
              <TableCell className="text-[#315a85]">{row.attendanceRate.toFixed(2)}%</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
