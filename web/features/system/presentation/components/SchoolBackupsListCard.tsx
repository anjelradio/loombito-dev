import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import type { SchoolBackup } from "@/features/system/domain/entities/school-backup";

import CreateSchoolBackupButton from "./CreateSchoolBackupButton";

type SchoolBackupsListCardProps = {
  schoolId: string;
  backups: SchoolBackup[];
};

export default function SchoolBackupsListCard({ schoolId, backups }: SchoolBackupsListCardProps) {
  const formatDate = (value: string) =>
    new Intl.DateTimeFormat("es-BO", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(new Date(value));

  return (
    <AccentCard variant="base" eyebrow="Backups" title="Copias de seguridad" className="p-5">
      <div className="mb-3 flex items-center justify-end">
        <CreateSchoolBackupButton schoolId={schoolId} />
      </div>

      <div className="space-y-3 rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-3.5">
        {backups.length ? (
          <div className="space-y-2">
            {backups.map((backup) => (
              <div key={backup.id} className="rounded-lg border border-[#dbe9f8] bg-white p-3 text-sm text-[#52749a]">
                <p className="font-semibold text-[#1f4d7d]">{backup.fileName}</p>
                <p className="mt-1 text-xs text-[#5d80a7]">{formatDate(backup.createdDate)}</p>
              </div>
            ))}
          </div>
        ) : (
          <div className="rounded-lg border border-[#dbe9f8] bg-white p-3 text-sm text-[#52749a]">
            Aun no hay copias de seguridad generadas.
          </div>
        )}
      </div>
    </AccentCard>
  );
}
