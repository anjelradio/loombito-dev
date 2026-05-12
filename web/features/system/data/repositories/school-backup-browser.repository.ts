import { schoolBackupBrowserApi } from "../api/school-backup-browser-api";

export const schoolBackupBrowserRepository = {
  createSchoolBackup(schoolId: string) {
    return schoolBackupBrowserApi.createSchoolBackup(schoolId);
  },
};
