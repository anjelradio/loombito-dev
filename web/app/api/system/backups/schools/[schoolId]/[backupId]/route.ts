import { NextResponse } from "next/server";

import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";

type RouteContext = {
  params: Promise<{ schoolId: string; backupId: string }>;
};

export async function DELETE(_: Request, context: RouteContext) {
  const token = await getToken();
  if (!token) return NextResponse.json({ detail: "No autorizado" }, { status: 401 });

  const { schoolId, backupId } = await context.params;
  const response = await fetch(`${env.API_URL}/system/backups/schools/${schoolId}/${backupId}`, {
    method: "DELETE",
    headers: { Authorization: `Bearer ${token}` },
  });

  const data = await response.json().catch(() => null);
  if (!response.ok) {
    return NextResponse.json(data ?? { detail: "No se pudo eliminar backup" }, { status: response.status });
  }

  return NextResponse.json(data, { status: 200 });
}
