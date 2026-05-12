"use client";

import { useEffect, useMemo, useRef, useState } from "react";

import type { TeacherAssignmentContextCourseGroup } from "@/features/academic/domain/entities/teacher-assignment-context";
import { reportBrowserRepository } from "@/features/reports/data/repositories/report-browser.repository";
import { SubmitButton } from "@/features/shared/components/forms/SubmitButton";
import AppModal from "@/features/shared/components/modals/AppModal";
import { ModalSecondaryButton } from "@/features/shared/components/modals/ModalSecondaryButton";
import { appToast } from "@/features/shared/components/toast/toast";
import SelectableChips from "@/features/shared/components/ui/SelectableChips";

import ReportAssignmentGroupsSelectorCard from "./ReportAssignmentGroupsSelectorCard";

const specificColumns = [
  { value: "student_last_name", label: "Apellido" },
  { value: "student_first_name", label: "Nombre" },
  { value: "attendance_date", label: "Fecha" },
  { value: "status_name", label: "Estado" },
  { value: "observation", label: "Observacion" },
] as const;

type AttendanceReportAssignmentPanelProps = {
  schoolId: string;
  groups: TeacherAssignmentContextCourseGroup[];
};

export default function AttendanceReportAssignmentPanel({
  schoolId,
  groups,
}: AttendanceReportAssignmentPanelProps) {
  const [open, setOpen] = useState(false);
  const [assignmentId, setAssignmentId] = useState("");
  const [courseName, setCourseName] = useState("");
  const [subjectName, setSubjectName] = useState("");
  const [format, setFormat] = useState<"xlsx" | "pdf">("xlsx");
  const [mode, setMode] = useState<"general" | "student_specific" | "audio">("general");
  const [columns, setColumns] = useState<string[]>(specificColumns.map((item) => item.value));

  const [fromDate, setFromDate] = useState("");
  const [toDate, setToDate] = useState("");
  const [studentLastName, setStudentLastName] = useState("");
  const [studentFirstName, setStudentFirstName] = useState("");
  const [attendanceStatusFilter, setAttendanceStatusFilter] = useState<"all" | "presente" | "falta" | "licencia">("all");
  const [audioBlob, setAudioBlob] = useState<Blob | null>(null);
  const [recording, setRecording] = useState(false);
  const [processingAudio, setProcessingAudio] = useState(false);
  const [audioDurationSec, setAudioDurationSec] = useState(0);
  const [audioLevel, setAudioLevel] = useState(0);

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const audioChunksRef = useRef<BlobPart[]>([]);
  const audioContextRef = useRef<AudioContext | null>(null);
  const analyserRef = useRef<AnalyserNode | null>(null);
  const animationFrameRef = useRef<number | null>(null);
  const startedAtRef = useRef<number | null>(null);

  const canSubmit = useMemo(() => {
    if (!assignmentId) return false;
    if (mode === "general") return true;
    if (mode === "audio") return !!audioBlob && !processingAudio;
    return columns.length > 0 && (!!studentLastName.trim() || !!studentFirstName.trim());
  }, [assignmentId, mode, columns, studentLastName, studentFirstName, audioBlob, processingAudio]);

  useEffect(() => {
    return () => {
      stopAudioPipeline();
    };
  }, []);

  const stopAudioPipeline = () => {
    if (animationFrameRef.current) {
      cancelAnimationFrame(animationFrameRef.current);
      animationFrameRef.current = null;
    }
    analyserRef.current = null;
    if (audioContextRef.current) {
      void audioContextRef.current.close();
      audioContextRef.current = null;
    }
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }
    mediaRecorderRef.current = null;
  };

  const animateAudioMeter = () => {
    const analyser = analyserRef.current;
    if (!analyser) return;

    const data = new Uint8Array(analyser.fftSize);
    const loop = () => {
      analyser.getByteTimeDomainData(data);
      let sumSquares = 0;
      for (let index = 0; index < data.length; index += 1) {
        const value = (data[index] - 128) / 128;
        sumSquares += value * value;
      }
      const rms = Math.sqrt(sumSquares / data.length);
      setAudioLevel(Math.min(1, rms * 3));

      if (startedAtRef.current) {
        setAudioDurationSec(Math.max(0, Math.floor((Date.now() - startedAtRef.current) / 1000)));
      }
      animationFrameRef.current = requestAnimationFrame(loop);
    };
    animationFrameRef.current = requestAnimationFrame(loop);
  };

  const startRecording = async () => {
    if (!navigator.mediaDevices?.getUserMedia || typeof MediaRecorder === "undefined") {
      appToast.error("Tu navegador no soporta grabacion de audio");
      return;
    }

    try {
      setAudioBlob(null);
      setAudioDurationSec(0);
      setAudioLevel(0);
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;

      const mimeType = MediaRecorder.isTypeSupported("audio/webm") ? "audio/webm" : "audio/mp4";
      const recorder = new MediaRecorder(stream, { mimeType });
      mediaRecorderRef.current = recorder;
      audioChunksRef.current = [];

      const audioContext = new AudioContext();
      audioContextRef.current = audioContext;
      const source = audioContext.createMediaStreamSource(stream);
      const analyser = audioContext.createAnalyser();
      analyser.fftSize = 2048;
      source.connect(analyser);
      analyserRef.current = analyser;
      animateAudioMeter();

      recorder.ondataavailable = (event) => {
        if (event.data.size > 0) audioChunksRef.current.push(event.data);
      };

      recorder.onstop = () => {
        const blob = new Blob(audioChunksRef.current, { type: recorder.mimeType || "audio/webm" });
        if (blob.size > 0) {
          setAudioBlob(blob);
        }
        setRecording(false);
        setAudioLevel(0);
        stopAudioPipeline();
      };

      recorder.start();
      startedAtRef.current = Date.now();
      setRecording(true);
    } catch {
      appToast.error("No se pudo acceder al microfono");
      stopAudioPipeline();
      setRecording(false);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== "inactive") {
      mediaRecorderRef.current.stop();
    }
  };

  const handleSelectAssignment = (nextAssignmentId: string, nextCourseName: string, nextSubjectName: string) => {
    setAssignmentId(nextAssignmentId);
    setCourseName(nextCourseName);
    setSubjectName(nextSubjectName);
    setOpen(true);
  };

  const handleSubmit = async (formData: FormData) => {
    const summary = String(formData.get("summary") || "").trim();

    if (mode === "audio") {
      if (!audioBlob) {
        appToast.error("Graba un audio antes de generar el reporte");
        return;
      }

      setProcessingAudio(true);
      try {
        const payload = new FormData();
        payload.set("schoolId", schoolId);
        payload.set("assignmentId", assignmentId);
        payload.set("format", format);
        payload.set("audio", new File([audioBlob], "consulta_asistencia.webm", { type: audioBlob.type || "audio/webm" }));

        const response = await fetch("/api/intelligence/attendance/export-from-audio", {
          method: "POST",
          body: payload,
        });

        if (!response.ok) {
          const data = await response.json().catch(() => null);
          appToast.error(data?.message ?? "No se pudo generar el reporte desde audio");
          return;
        }

        const blob = await response.blob();
        const disposition = response.headers.get("content-disposition") || "";
        const fileNameMatch = disposition.match(/filename="([^"]+)"/);
        const fileName = fileNameMatch?.[1] ?? "reporte_asistencia_audio.xlsx";
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = url;
        link.download = fileName;
        document.body.appendChild(link);
        link.click();
        link.remove();
        URL.revokeObjectURL(url);

        appToast.success("Reporte generado desde audio");
        setOpen(false);
      } finally {
        setProcessingAudio(false);
      }
      return;
    }

    const response = await reportBrowserRepository.exportAttendanceReport({
      schoolId,
      assignmentId,
      fromDate,
      toDate,
      mode,
      studentLastName: mode === "student_specific" ? studentLastName.trim() : undefined,
      studentFirstName: mode === "student_specific" ? studentFirstName.trim() : undefined,
      attendanceStatusFilter: mode === "student_specific" ? attendanceStatusFilter : undefined,
      columns: mode === "general"
        ? [
            "student_last_name",
            "student_first_name",
            "total_sessions",
            "present_count",
            "absence_count",
            "license_count",
            "attendance_percentage",
            "absence_percentage",
          ]
        : columns,
      format,
      summary: summary || null,
    });

    if (!response.ok) {
      appToast.error(response.errors[0] ?? "No se pudo generar el reporte de asistencias");
      return;
    }

    const url = URL.createObjectURL(response.data.blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = response.data.fileName;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);

    appToast.success("Reporte generado y descargado");
    setOpen(false);
  };

  return (
    <>
      <ReportAssignmentGroupsSelectorCard groups={groups} onSelect={handleSelectAssignment} />

      <AppModal
        open={open}
        onOpenChange={setOpen}
        title={`Reporte de asistencias: ${subjectName}`}
        description={`Curso: ${courseName}. Selecciona modo, rango de fechas y descarga.`}
        size="xl"
      >
        <form action={handleSubmit} className="space-y-5">
          <div className="space-y-2">
            <p className="text-sm font-semibold text-[#1E3A5F]">Modo</p>
            <SelectableChips
              options={[
                { value: "general", label: "General" },
                { value: "student_specific", label: "Especifico" },
                { value: "audio", label: "Audio" },
              ]}
              selectedValues={[mode]}
              onChange={(values) => setMode((values[0] as "general" | "student_specific" | "audio") || "general")}
            />
          </div>

          {mode !== "audio" ? (
            <>
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-[#1E3A5F]" htmlFor="fromDate">Desde</label>
                  <input id="fromDate" type="date" value={fromDate} onChange={(event) => setFromDate(event.target.value)} className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-[#1E3A5F]" htmlFor="toDate">Hasta</label>
                  <input id="toDate" type="date" value={toDate} onChange={(event) => setToDate(event.target.value)} className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]" />
                </div>
              </div>
              <p className="text-xs text-[#5b7ea5]">
                Fechas opcionales: solo desde = hasta hoy, solo hasta = desde inicio, vacio = todo el historial.
              </p>
            </>
          ) : null}

          {mode === "student_specific" ? (
            <>
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-[#1E3A5F]" htmlFor="studentLastName">Apellido</label>
                  <input id="studentLastName" value={studentLastName} onChange={(event) => setStudentLastName(event.target.value)} placeholder="Ej: Perez" className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-[#1E3A5F]" htmlFor="studentFirstName">Nombre</label>
                  <input id="studentFirstName" value={studentFirstName} onChange={(event) => setStudentFirstName(event.target.value)} placeholder="Ej: Juan" className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]" />
                </div>
              </div>

              <div className="space-y-2">
                <p className="text-sm font-semibold text-[#1E3A5F]">Tipo de asistencia</p>
                <SelectableChips
                  options={[
                    { value: "all", label: "Todas" },
                    { value: "falta", label: "Faltas" },
                    { value: "presente", label: "Presentes" },
                    { value: "licencia", label: "Licencias" },
                  ]}
                  selectedValues={[attendanceStatusFilter]}
                  onChange={(values) => setAttendanceStatusFilter((values[0] as "all" | "presente" | "falta" | "licencia") || "all")}
                />
              </div>

              <div className="space-y-2">
                <p className="text-sm font-semibold text-[#1E3A5F]">Columnas</p>
                <SelectableChips
                  options={specificColumns.map((item) => ({ value: item.value, label: item.label }))}
                  selectedValues={columns}
                  onChange={(values) => setColumns(values)}
                  multiple
                />
              </div>
            </>
          ) : mode === "general" ? (
            <div className="rounded-lg border border-[#cad8ea] bg-[#f8fbff] p-3 text-sm text-[#52749a]">
              El reporte general es estatico por estudiante: total de sesiones, presentes, faltas, licencias y porcentajes.
            </div>
          ) : (
            <div className="space-y-3 rounded-lg border border-[#cad8ea] bg-[#f8fbff] p-4">
              <p className="text-sm font-semibold text-[#1E3A5F]">Consulta por voz</p>
              <p className="text-xs text-[#5b7ea5]">
                Graba una instruccion en voz natural. Ejemplo: "reporte de faltas de Perez Juan, mostrar apellido, nombre, fecha y observacion".
              </p>

              <div className="rounded-md border border-[#d6e5f6] bg-white p-3">
                <div className="mb-2 flex items-center justify-between text-xs text-[#5b7ea5]">
                  <span>{recording ? "Grabando..." : audioBlob ? "Audio listo" : "Sin grabacion"}</span>
                  <span>{audioDurationSec}s</span>
                </div>
                <div className="flex h-10 items-end gap-1">
                  {Array.from({ length: 24 }).map((_, index) => {
                    const barLevel = recording
                      ? Math.max(8, Math.round((Math.sin(index + audioDurationSec) * 0.5 + 0.5) * 24 * audioLevel + 8))
                      : audioBlob
                        ? 12
                        : 6;
                    return (
                      <div
                        key={`bar-${index}`}
                        className="w-1 rounded bg-[#2b5f97]"
                        style={{ height: `${barLevel}px`, opacity: recording ? 0.9 : 0.45 }}
                      />
                    );
                  })}
                </div>
              </div>

              <div className="flex flex-wrap gap-2">
                {recording ? (
                  <button type="button" onClick={stopRecording} className="h-10 rounded-lg bg-[#9b3f3f] px-4 text-sm font-semibold text-white hover:bg-[#7f2f2f]">
                    Detener grabacion
                  </button>
                ) : (
                  <button type="button" onClick={startRecording} className="h-10 rounded-lg bg-[#1E3A5F] px-4 text-sm font-semibold text-white hover:bg-[#152B47]">
                    {audioBlob ? "Regrabar" : "Iniciar grabacion"}
                  </button>
                )}
              </div>
            </div>
          )}

          <div className="space-y-2">
            <label htmlFor="summary" className="text-sm font-semibold text-[#1E3A5F]">Descripcion (opcional)</label>
            <input id="summary" name="summary" placeholder="Ej: Reporte mensual de asistencias" className="h-11 w-full rounded-lg border border-[#cad8ea] bg-white px-3 text-sm text-[#1f4d7d]" />
          </div>

          <div className="space-y-2">
            <p className="text-sm font-semibold text-[#1E3A5F]">Formato</p>
            <SelectableChips
              options={[{ value: "xlsx", label: "Excel" }, { value: "pdf", label: "PDF" }]}
              selectedValues={[format]}
              onChange={(values) => setFormat((values[0] as "xlsx" | "pdf") || "xlsx")}
            />
          </div>

          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <ModalSecondaryButton onClick={() => setOpen(false)}>Cerrar</ModalSecondaryButton>
            <SubmitButton disabled={!canSubmit || recording || processingAudio} pendingText={mode === "audio" ? "Procesando audio..." : "Generando..."} className="h-12 bg-[#1E3A5F] px-5 font-semibold text-white hover:bg-[#152B47]">
              {mode === "audio" ? "Generar con audio" : "Generar y descargar"}
            </SubmitButton>
          </div>
        </form>
      </AppModal>
    </>
  );
}
