import { NextResponse } from "next/server";

import { getToken } from "@/features/shared/infrastructure/auth/get-token";
import { env } from "@/features/shared/infrastructure/config/env";

type RouteContext = {
  params: Promise<{ schoolId: string }>;
};

export async function GET(_: Request, context: RouteContext) {
  const token = await getToken();
  if (!token) return NextResponse.json({ detail: "No autorizado" }, { status: 401 });

  const { schoolId } = await context.params;
  const response = await fetch(`${env.API_URL}/system/backups/schools/${schoolId}`, {
    method: "GET",
    headers: { Authorization: `Bearer ${token}` },
    cache: "no-store",
  });

  const data = await response.json().catch(() => null);
  if (!response.ok) {
    return NextResponse.json(data ?? { detail: "No se pudo listar backups" }, { status: response.status });
  }

  return NextResponse.json(data, { status: 200 });
}

export async function POST(_: Request, context: RouteContext) {
  const token = await getToken();
  if (!token) return NextResponse.json({ detail: "No autorizado" }, { status: 401 });

  const { schoolId } = await context.params;
  const response = await fetch(`${env.API_URL}/system/backups/schools/${schoolId}`, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}` },
  });

  const data = await response.json().catch(() => null);
  if (!response.ok) {
    return NextResponse.json(data ?? { detail: "No se pudo crear backup" }, { status: response.status });
  }

  return NextResponse.json(data, { status: 200 });
}
