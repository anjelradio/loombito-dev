import type { StudentCommunication } from "@/features/communications/domain/entities/student-communication";

import DeleteStudentCommunicationButton from "./DeleteStudentCommunicationButton";
import EditStudentCommunicationButton from "./EditStudentCommunicationButton";

type StudentCommunicationListItemCardProps = {
  schoolId: string;
  communication: StudentCommunication;
};

export default function StudentCommunicationListItemCard({
  schoolId,
  communication,
}: StudentCommunicationListItemCardProps) {
  return (
    <article className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 shadow-[0_16px_32px_-28px_rgba(10,31,61,0.5)]">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1">
          <p className="text-xs uppercase tracking-[0.14em] text-[#6a8cb2]">Comunicado</p>
          <p className="mt-1 text-base font-semibold text-[#1f4d7d]">{communication.title}</p>
          <p className="mt-2 whitespace-pre-wrap text-sm text-[#4e7399]">{communication.body}</p>
        </div>
        <p className="text-xs font-semibold text-[#315a85]">{communication.createdDate.slice(0, 10)}</p>
      </div>

      <div className="mt-4 flex justify-end gap-2">
        <EditStudentCommunicationButton schoolId={schoolId} communication={communication} />
        <DeleteStudentCommunicationButton schoolId={schoolId} communication={communication} />
      </div>
    </article>
  );
}
