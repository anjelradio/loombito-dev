import type { AuditLogItem, AuditLogList } from "@/features/system/domain/entities/audit-log";

import type { AuditLogItemResponseDto, AuditLogListResponseDto } from "../schemas/audit-log-response.schema";

export function toAuditLogItemEntity(dto: AuditLogItemResponseDto): AuditLogItem {
  return {
    id: dto.id,
    createdDate: dto.created_date,
    scope: dto.scope,
    action: dto.action,
    status: dto.status,
    actorUserId: dto.actor_user_id,
    actorIdentifier: dto.actor_identifier,
    schoolId: dto.school_id,
    description: dto.description,
    ip: dto.ip,
  };
}

export function toAuditLogListEntity(dto: AuditLogListResponseDto): AuditLogList {
  return {
    logs: dto.logs.map(toAuditLogItemEntity),
    page: dto.page,
    perPage: dto.per_page,
    totalPages: dto.total_pages,
    hasPrev: dto.has_prev,
    hasNext: dto.has_next,
  };
}
