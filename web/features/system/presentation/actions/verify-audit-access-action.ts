"use server";

import { auditRepository } from "@/features/system/data/repositories";

export async function verifyAuditAccessKey(accessKey: string) {
  return auditRepository.verifyAccessKey(accessKey);
}
