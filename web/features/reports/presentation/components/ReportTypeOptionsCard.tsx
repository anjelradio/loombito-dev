import Link from "next/link";

import { AccentCard } from "@/features/shared/components/cards/AccentCard";

type ReportOption = {
  key: string;
  title: string;
  description: string;
  href: string;
};

type ReportTypeOptionsCardProps = {
  title?: string;
  description?: string;
  options: ReportOption[];
};

export default function ReportTypeOptionsCard({
  title = "Tipos de reporte",
  description = "Selecciona el tipo de reporte que quieres configurar y descargar.",
  options,
}: ReportTypeOptionsCardProps) {
  return (
    <AccentCard variant="base" eyebrow="Opciones" title={title} description={description} className="p-5">
      <div className="space-y-3">
        {options.map((option) => (
          <Link
            key={option.key}
            href={option.href}
            className="block rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-3.5 transition-colors hover:bg-[#eef6ff]"
          >
            <p className="text-sm font-semibold text-[#1f4d7d]">{option.title}</p>
            <p className="mt-1 text-xs leading-relaxed text-[#5b7ea5]">{option.description}</p>
          </Link>
        ))}
      </div>
    </AccentCard>
  );
}
