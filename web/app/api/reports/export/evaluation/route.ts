import { NextResponse } from "next/server";

import { env } from "@/features/shared/infrastructure/config/env";
import { getToken } from "@/features/shared/infrastructure/auth/get-token";

export async function POST(request: Request) {
  try {
    const token = await getToken();
    if (!token) {
      return NextResponse.json({ message: "No autorizado" }, { status: 401 });
    }

    const body = await request.json();
    const schoolId = String(body.schoolId || "");
    const evaluationId = body.evaluationId ? String(body.evaluationId) : "";
    const assignmentId = body.assignmentId ? String(body.assignmentId) : "";
    const columns = Array.isArray(body.columns) ? body.columns : [];
    const format = String(body.format || "xlsx");
    const summary = body.summary ?? null;

    if (!schoolId || !columns.length || (!evaluationId && !assignmentId)) {
      return NextResponse.json({ message: "Datos incompletos para generar reporte" }, { status: 400 });
    }

    const response = await fetch(`${env.API_URL}/reports/schools/${schoolId}/export/evaluation`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        evaluation_id: evaluationId || null,
        assignment_id: assignmentId || null,
        columns,
        format,
        summary,
      }),
    });

    if (!response.ok) {
      const data = await response.json().catch(() => null);
      return NextResponse.json({ message: data?.detail ?? "No se pudo exportar el reporte" }, { status: response.status });
    }

    const fileBuffer = await response.arrayBuffer();
    const contentType = response.headers.get("content-type") || "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    const disposition = response.headers.get("content-disposition") || "attachment; filename=\"reporte_evaluaciones.xlsx\"";

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
