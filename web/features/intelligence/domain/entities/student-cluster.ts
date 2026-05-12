export type StudentClusterRow = {
  studentId: string;
  firstName: string;
  lastName: string;
  clusterId: number;
  clusterLabel: "alto_rendimiento" | "rendimiento_medio" | "en_riesgo";
  finalScore: number;
  attendanceRate: number;
};

export type StudentClusterSnapshot = {
  assignmentId: string;
  termId: string;
  schoolId: string;
  featuresVersion: string | null;
  kValue: number | null;
  inertia: number | null;
  silhouetteScore: number | null;
  trainedAt: string | null;
  students: StudentClusterRow[];
};
