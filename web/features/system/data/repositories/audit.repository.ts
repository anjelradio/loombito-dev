import { auditApi } from "../api/audit-api";

export const auditRepository = {
  requestAccessKey() {
    return auditApi.requestAccessKey();
  },
  verifyAccessKey(accessKey: string) {
    return auditApi.verifyAccessKey(accessKey);
  },
  getSchoolAuditLogs(schoolId: string, page?: number, perPage?: number) {
    return auditApi.getSchoolAuditLogs(schoolId, page, perPage);
  },
};
