class SubjectPerformance {
  final String subjectName;
  final double average;

  SubjectPerformance({
    required this.subjectName,
    required this.average,
  });
}

class StudentStatisticsData {
  final int totalPresences;
  final int totalAbsences;
  final int totalLicenses;
  final double attendancePercentage;
  final double currentAverage;
  final List<SubjectPerformance> strengths;
  final List<SubjectPerformance> weaknesses;

  StudentStatisticsData({
    required this.totalPresences,
    required this.totalAbsences,
    required this.totalLicenses,
    required this.attendancePercentage,
    required this.currentAverage,
    required this.strengths,
    required this.weaknesses,
  });
}

class StudentPredictionsData {
  final String? clusterLabel;
  final double? projectedFinalScore;
  final double? failureProbability;
  final DateTime? calculatedAt;

  StudentPredictionsData({
    this.clusterLabel,
    this.projectedFinalScore,
    this.failureProbability,
    this.calculatedAt,
  });
}

class StudentStatistics {
  final StudentStatisticsData statistics;
  final StudentPredictionsData predictions;

  StudentStatistics({
    required this.statistics,
    required this.predictions,
  });
}
