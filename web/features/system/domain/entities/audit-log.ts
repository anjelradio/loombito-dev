export type AuditLogItem = {
  id: string;
  createdDate: string;
  scope: "system" | "school";
  action: string;
  status: "success" | "failed";
  actorUserId: string | null;
  actorIdentifier: string | null;
  schoolId: string | null;
  description: string;
  ip: string;
};

export type AuditLogList = {
  logs: AuditLogItem[];
  page: number;
  perPage: number;
  totalPages: number;
  hasPrev: boolean;
  hasNext: boolean;
};
