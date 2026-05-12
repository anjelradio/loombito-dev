import type { SchoolBackup } from "@/features/system/domain/entities/school-backup";

import type {
  CreateSchoolBackupResponseDto,
  SchoolBackupResponseDto,
} from "../schemas/school-backup-response.schema";

export function toSchoolBackupEntity(dto: SchoolBackupResponseDto): SchoolBackup {
  return {
    id: dto.id,
    schoolId: dto.school_id,
    createdByUserId: dto.created_by_user_id,
    fileName: dto.file_name,
    fileSizeBytes: dto.file_size_bytes,
    checksumSha256: dto.checksum_sha256,
    status: dto.status,
    createdDate: dto.created_date,
    restoredDate: dto.restored_date,
  };
}

export function toCreatedSchoolBackupEntity(dto: CreateSchoolBackupResponseDto): SchoolBackup {
  return toSchoolBackupEntity(dto.backup);
}
