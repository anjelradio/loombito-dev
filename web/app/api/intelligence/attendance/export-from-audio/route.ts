import { NextResponse } from "next/server";

import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";

export async function POST(request: Request) {
  try {
    const token = await getToken();
    if (!token) {
      return NextResponse.json({ message: "No autorizado" }, { status: 401 });
    }

    const incoming = await request.formData();
    const schoolId = String(incoming.get("schoolId") || "");
    const assignmentId = String(incoming.get("assignmentId") || "");
    const format = String(incoming.get("format") || "xlsx");
    const audio = incoming.get("audio");

    if (!schoolId || !assignmentId || !(audio instanceof File)) {
      return NextResponse.json({ message: "Datos incompletos para procesar audio" }, { status: 400 });
    }

    const payload = new FormData();
    payload.set("audio", audio, audio.name || "audio.webm");

    const backendResponse = await fetch(
      `${env.API_URL}/intelligence/schools/${schoolId}/assignments/${assignmentId}/attendance-reports/export-from-audio?format=${format}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: payload,
      },
    );

    if (!backendResponse.ok) {
      const data = await backendResponse.json().catch(() => null);
      return NextResponse.json({ message: data?.detail ?? "No se pudo generar reporte desde audio" }, { status: backendResponse.status });
    }

    const fileBuffer = await backendResponse.arrayBuffer();
    const contentType = backendResponse.headers.get("content-type") || "application/octet-stream";
    const disposition = backendResponse.headers.get("content-disposition") || "attachment; filename=\"reporte_asistencia_audio.xlsx\"";

    return new Response(fileBuffer, {
      status: 200,
      headers: {
        "Content-Type": contentType,
        "Content-Disposition": disposition,
      },
    });
  } catch {
    return NextResponse.json({ message: "Error de conexion. Intenta mas tarde." }, { status: 500 });
  }
}
