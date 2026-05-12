"use server";

import { auditRepository } from "@/features/system/data/repositories";

export async function requestAuditAccessKey() {
  return auditRepository.requestAccessKey();
}
