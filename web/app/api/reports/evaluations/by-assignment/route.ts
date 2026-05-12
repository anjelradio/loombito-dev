import { NextResponse } from "next/server";

import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";

function toMessage(detail: unknown, fallback: string) {
  if (typeof detail === "string" && detail.trim()) return detail;
  if (Array.isArray(detail)) {
    const firstWithMsg = detail.find(
      (item) => typeof item === "object" && item !== null && "msg" in item,
    ) as { msg?: unknown } | undefined;
    if (typeof firstWithMsg?.msg === "string" && firstWithMsg.msg.trim()) {
      return firstWithMsg.msg;
    }
  }
  return fallback;
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const schoolId = searchParams.get("schoolId") || "";
  const assignmentId = searchParams.get("assignmentId") || "";

  if (!schoolId || !assignmentId) {
    return NextResponse.json({ message: "Faltan parametros de consulta" }, { status: 400 });
  }

  const token = await getToken();
  if (!token) {
    return NextResponse.json({ message: "No autorizado" }, { status: 401 });
  }

  const backendResponse = await fetch(
    `${env.API_URL}/evaluations/schools/${schoolId}/assignments/${assignmentId}/evaluations?page=1&per_page=100`,
    {
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      cache: "no-store",
    },
  );

  if (!backendResponse.ok) {
    const data = await backendResponse.json().catch(() => null);
    return NextResponse.json(
      { message: toMessage(data?.detail, "No se pudieron obtener evaluaciones") },
      { status: backendResponse.status },
    );
  }

  const data = await backendResponse.json();
  const options = Array.isArray(data?.evaluations)
    ? data.evaluations.map((item: { id: string; name: string }) => ({ id: item.id, name: item.name }))
    : [];

  return NextResponse.json({ options });
}
