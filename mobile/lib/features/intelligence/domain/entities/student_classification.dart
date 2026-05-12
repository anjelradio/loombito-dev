class IntelligenceTermOption {
  final String id;
  final String name;
  final bool isActive;

  IntelligenceTermOption({
    required this.id,
    required this.name,
    required this.isActive,
  });
}

class StudentClusterRow {
  final String studentId;
  final String firstName;
  final String lastName;
  final int clusterId;
  final String clusterLabel;
  final double finalScore;
  final double attendanceRate;

  StudentClusterRow({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.clusterId,
    required this.clusterLabel,
    required this.finalScore,
    required this.attendanceRate,
  });
}

class StudentClusterSnapshot {
  final String assignmentId;
  final String termId;
  final String schoolId;
  final String? featuresVersion;
  final int? kValue;
  final double? inertia;
  final double? silhouetteScore;
  final String? trainedAt;
  final List<StudentClusterRow> students;

  StudentClusterSnapshot({
    required this.assignmentId,
    required this.termId,
    required this.schoolId,
    required this.featuresVersion,
    required this.kValue,
    required this.inertia,
    required this.silhouetteScore,
    required this.trainedAt,
    required this.students,
  });
}

class RecalculateStudentClusterSummary {
  final int processedStudents;
  final String assignmentId;
  final String termId;

  RecalculateStudentClusterSummary({
    required this.processedStudents,
    required this.assignmentId,
    required this.termId,
  });
}
