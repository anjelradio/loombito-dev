import { schoolBackupBrowserApi } from "../api/school-backup-browser-api";

export const schoolBackupBrowserRepository = {
  createSchoolBackup(schoolId: string) {
    return schoolBackupBrowserApi.createSchoolBackup(schoolId);
  },
  restoreSchoolBackup(schoolId: string, backupId: string) {
    return schoolBackupBrowserApi.restoreSchoolBackup(schoolId, backupId);
  },
  deleteSchoolBackup(schoolId: string, backupId: string) {
    return schoolBackupBrowserApi.deleteSchoolBackup(schoolId, backupId);
  },
};
