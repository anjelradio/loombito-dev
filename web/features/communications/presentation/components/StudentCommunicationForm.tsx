import type { StudentCommunication } from "@/features/communications/domain/entities/student-communication";
import { FormTextField } from "@/features/shared/components/forms/FormTextField";

type StudentCommunicationFormProps = {
  communication?: StudentCommunication;
};

export default function StudentCommunicationForm({ communication }: StudentCommunicationFormProps) {
  return (
    <div className="space-y-5">
      <FormTextField
        id="title"
        name="title"
        label="Titulo"
        placeholder="Ej: Recordatorio de tareas"
        defaultValue={communication?.title}
        required
      />
      <div className="space-y-2">
        <label htmlFor="body" className="text-sm font-semibold text-[#1E3A5F]">
          Descripcion
        </label>
        <textarea
          id="body"
          name="body"
          className="min-h-32 w-full rounded-xl border border-[#c6d7ea] bg-white px-3 py-2 text-sm text-[#27476d] outline-none transition focus:border-[#6ea3d8]"
          placeholder="Describe el comunicado para la familia del estudiante"
          defaultValue={communication?.body}
          required
        />
      </div>
    </div>
  );
}
