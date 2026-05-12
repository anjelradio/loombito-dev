import { NextResponse } from "next/server";

import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";

type RouteContext = {
  params: Promise<{ schoolId: string; backupId: string }>;
};

export async function POST(request: Request, context: RouteContext) {
  const token = await getToken();
  if (!token) return NextResponse.json({ detail: "No autorizado" }, { status: 401 });

  const { schoolId, backupId } = await context.params;
  const body = await request.json().catch(() => ({}));

  const response = await fetch(`${env.API_URL}/system/backups/schools/${schoolId}/${backupId}/restore`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ confirm_text: body.confirm_text ?? "" }),
  });

  const data = await response.json().catch(() => null);
  if (!response.ok) {
    return NextResponse.json(data ?? { detail: "No se pudo restaurar backup" }, { status: response.status });
  }

  return NextResponse.json(data, { status: 200 });
}
