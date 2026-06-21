import 'package:mobile/features/intelligence/domain/domain.dart';

class IntelligenceMapper {
  static IntelligenceTermOption termOptionFromJson(Map<String, dynamic> json) {
    return IntelligenceTermOption(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      isActive: json['is_active'] == true,
    );
  }

  static StudentClusterRow clusterRowFromJson(Map<String, dynamic> json) {
    return StudentClusterRow(
      studentId: json['student_id'].toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      clusterId: (json['cluster_id'] as num?)?.toInt() ?? 0,
      clusterLabel: (json['cluster_label'] ?? '').toString(),
      finalScore: (json['final_score'] as num?)?.toDouble() ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 0,
    );
  }

  static StudentClusterSnapshot snapshotFromJson(Map<String, dynamic> json) {
    final rows = (json['students'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return StudentClusterSnapshot(
      assignmentId: json['assignment_id'].toString(),
      termId: json['term_id'].toString(),
      schoolId: json['school_id'].toString(),
      featuresVersion: json['features_version']?.toString(),
      kValue: (json['k_value'] as num?)?.toInt(),
      inertia: (json['inertia'] as num?)?.toDouble(),
      silhouetteScore: (json['silhouette_score'] as num?)?.toDouble(),
      trainedAt: json['trained_at']?.toString(),
      students: rows.map(clusterRowFromJson).toList(),
    );
  }

  static RecalculateStudentClusterSummary recalculateSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    return RecalculateStudentClusterSummary(
      processedStudents: (json['processed_students'] as num?)?.toInt() ?? 0,
      assignmentId: json['assignment_id'].toString(),
      termId: json['term_id'].toString(),
    );
  }
  static StudentStatistics studentStatisticsFromJson(Map<String, dynamic> json) {
    final statsData = json['statistics'] as Map<String, dynamic>? ?? {};
    final preds = json['predictions'] as Map<String, dynamic>? ?? {};

    return StudentStatistics(
      statistics: StudentStatisticsData(
        totalPresences: (statsData['total_presences'] as num?)?.toInt() ?? 0,
        totalAbsences: (statsData['total_absences'] as num?)?.toInt() ?? 0,
        totalLicenses: (statsData['total_licenses'] as num?)?.toInt() ?? 0,
        attendancePercentage: (statsData['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
        currentAverage: (statsData['current_average'] as num?)?.toDouble() ?? 0.0,
        strengths: (statsData['strengths'] as List<dynamic>?)?.map(
          (s) => SubjectPerformance(
            subjectName: (s as Map<String, dynamic>)['subject_name']?.toString() ?? '',
            average: (s['average'] as num?)?.toDouble() ?? 0.0,
          ),
        ).toList() ?? [],
        weaknesses: (statsData['weaknesses'] as List<dynamic>?)?.map(
          (w) => SubjectPerformance(
            subjectName: (w as Map<String, dynamic>)['subject_name']?.toString() ?? '',
            average: (w['average'] as num?)?.toDouble() ?? 0.0,
          ),
        ).toList() ?? [],
      ),
      predictions: StudentPredictionsData(
        clusterLabel: preds['cluster_label']?.toString(),
        projectedFinalScore: (preds['projected_final_score'] as num?)?.toDouble(),
        failureProbability: (preds['failure_probability'] as num?)?.toDouble(),
        calculatedAt: preds['calculated_at'] != null 
            ? DateTime.tryParse(preds['calculated_at'].toString()) 
            : null,
      ),
    );
  }
}
