import { schoolBackupApi } from "../api/school-backup-api";

export const schoolBackupRepository = {
  getSchoolBackups(schoolId: string) {
    return schoolBackupApi.getSchoolBackups(schoolId);
  },
  createSchoolBackup(schoolId: string) {
    return schoolBackupApi.createSchoolBackup(schoolId);
  },
};
