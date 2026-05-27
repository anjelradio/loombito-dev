import type {
  StudentCreateData,
  StudentInviteExportData,
  StudentUpdateData,
} from "../../../schemas/students/request";
import type { StudentGradeUpsertData } from "../../../schemas/gradebook/request";

export function toStudentCreateRequestDto(data: StudentCreateData) {
  return {
    first_name: data.firstName,
    last_name: data.lastName,
    birth_date: data.birthDate,
  };
}

export function toStudentUpdateRequestDto(data: StudentUpdateData) {
  return {
    first_name: data.firstName,
    last_name: data.lastName,
    birth_date: data.birthDate,
  };
}

export function toStudentGradeUpsertRequestDto(data: StudentGradeUpsertData) {
  return {
    score: data.score,
    observation: data.observation || null,
  };
}

export function toStudentInviteExportRequestDto(data: StudentInviteExportData) {
  return {
    expires_at: data.expiresAt,
    max_uses: data.maxUses,
  };
}
