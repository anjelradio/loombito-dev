export type SchoolBackup = {
  id: string;
  schoolId: string;
  createdByUserId: string;
  fileName: string;
  fileSizeBytes: number;
  checksumSha256: string;
  status: string;
  createdDate: string;
  restoredDate: string | null;
};
