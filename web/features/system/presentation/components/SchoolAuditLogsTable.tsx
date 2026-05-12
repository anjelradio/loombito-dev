import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import type { AuditLogItem } from "@/features/system/domain/entities/audit-log";
import { formatBoliviaDateTime } from "@/features/shared/infrastructure/date-time/date-time";

type SchoolAuditLogsTableProps = {
  rows: AuditLogItem[];
};

export default function SchoolAuditLogsTable({ rows }: SchoolAuditLogsTableProps) {
  if (!rows.length) {
    return (
      <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
        No hay registros en la bitacora para esta escuela.
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-xl border border-[#d5e3f3] bg-[#f8fbff]">
      <div className="max-h-[600px] overflow-auto">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead className="sticky top-0 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">
                Fecha
              </TableHead>
              <TableHead className="sticky top-0 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">
                Accion
              </TableHead>
              <TableHead className="sticky top-0 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">
                Estado
              </TableHead>
              <TableHead className="sticky top-0 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">
                Usuario
              </TableHead>
              <TableHead className="sticky top-0 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">
                IP
              </TableHead>
              <TableHead className="sticky top-0 bg-[#f8fbff] text-xs uppercase tracking-[0.12em] text-[#5f82aa]">
                Descripcion
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((row) => (
              <TableRow key={row.id} className="border-[#dbe9f8] hover:bg-[#f1f7ff]">
                <TableCell className="text-[#315a85]">{formatBoliviaDateTime(row.createdDate)}</TableCell>
                <TableCell className="font-medium uppercase text-[#234f7e]">{row.action}</TableCell>
                <TableCell>
                  <span
                    className={
                      row.status === "success"
                        ? "inline-flex rounded-full border border-[#b8e3ca] bg-[#eafaf1] px-2.5 py-1 text-xs font-semibold uppercase tracking-wide text-[#2d7b4f]"
                        : "inline-flex rounded-full border border-[#f0c9c9] bg-[#fff1f1] px-2.5 py-1 text-xs font-semibold uppercase tracking-wide text-[#a64646]"
                    }
                  >
                    {row.status}
                  </span>
                </TableCell>
                <TableCell className="text-[#315a85]">{row.actorIdentifier ?? row.actorUserId ?? "-"}</TableCell>
                <TableCell className="text-[#315a85]">{row.ip}</TableCell>
                <TableCell className="text-[#315a85]">{row.description}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
