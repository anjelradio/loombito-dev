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
    const assignmentId = String(body.assignmentId || "");
    const fromDate = typeof body.fromDate === "string" && body.fromDate.trim() ? body.fromDate : null;
    const toDate = typeof body.toDate === "string" && body.toDate.trim() ? body.toDate : null;
    const mode = String(body.mode || "general");
    const studentLastName = typeof body.studentLastName === "string" ? body.studentLastName : null;
    const studentFirstName = typeof body.studentFirstName === "string" ? body.studentFirstName : null;
    const attendanceStatusFilter = typeof body.attendanceStatusFilter === "string" ? body.attendanceStatusFilter : null;
    const columns = Array.isArray(body.columns) ? body.columns : [];
    const format = String(body.format || "xlsx");
    const summary = body.summary ?? null;

    if (!schoolId || !assignmentId || !columns.length) {
      return NextResponse.json({ message: "Datos incompletos para generar reporte" }, { status: 400 });
    }

    const response = await fetch(`${env.API_URL}/reports/schools/${schoolId}/export/attendance`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        assignment_id: assignmentId,
        from_date: fromDate,
        to_date: toDate,
        mode,
        student_last_name: studentLastName,
        student_first_name: studentFirstName,
        attendance_status_filter: attendanceStatusFilter,
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
    const disposition = response.headers.get("content-disposition") || "attachment; filename=\"reporte_asistencia.xlsx\"";

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
