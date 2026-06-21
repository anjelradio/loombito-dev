import 'package:mobile/features/intelligence/data/api/api.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';

class IntelligenceRepository {
  final IntelligenceApi _api;

  IntelligenceRepository({required IntelligenceApi api}) : _api = api;

  Future<List<IntelligenceTermOption>> getTermOptions(String schoolId) {
    return _api.getTermOptions(schoolId);
  }

  Future<StudentClusterSnapshot> getStudentClusters(
    String schoolId,
    String assignmentId,
    String termId,
  ) {
    return _api.getStudentClusters(schoolId, assignmentId, termId);
  }

  Future<RecalculateStudentClusterSummary> recalculateStudentClusters(
    String schoolId,
    String assignmentId,
    String termId,
  ) {
    return _api.recalculateStudentClusters(schoolId, assignmentId, termId);
  }
  Future<StudentStatistics> getStudentStatistics(
    String schoolId,
    String studentId,
  ) {
    return _api.getStudentStatistics(schoolId, studentId);
  }
}
