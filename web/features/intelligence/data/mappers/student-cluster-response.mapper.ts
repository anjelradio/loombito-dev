import type { StudentClusterRow, StudentClusterSnapshot } from "@/features/intelligence/domain/entities/student-cluster";

import type {
  StudentClusterRowResponseDto,
  StudentClusterSnapshotResponseDto,
} from "../schemas/student-cluster-response.schema";

export function toStudentClusterRowEntity(dto: StudentClusterRowResponseDto): StudentClusterRow {
  return {
    studentId: dto.student_id,
    firstName: dto.first_name,
    lastName: dto.last_name,
    clusterId: dto.cluster_id,
    clusterLabel: dto.cluster_label,
    finalScore: dto.final_score,
    attendanceRate: dto.attendance_rate,
  };
}

export function toStudentClusterSnapshotEntity(
  dto: StudentClusterSnapshotResponseDto,
): StudentClusterSnapshot {
  return {
    assignmentId: dto.assignment_id,
    termId: dto.term_id,
    schoolId: dto.school_id,
    featuresVersion: dto.features_version,
    kValue: dto.k_value,
    inertia: dto.inertia,
    silhouetteScore: dto.silhouette_score,
    trainedAt: dto.trained_at,
    students: dto.students.map(toStudentClusterRowEntity),
  };
}
