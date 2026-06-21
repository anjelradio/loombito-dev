import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/intelligence/data/mappers/mappers.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';

class IntelligenceApi {
  late final Dio dio;

  IntelligenceApi({required String accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<List<IntelligenceTermOption>> getTermOptions(String schoolId) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/term-average-options',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(IntelligenceMapper.termOptionFromJson).toList();
  }

  Future<StudentClusterSnapshot> getStudentClusters(
    String schoolId,
    String assignmentId,
    String termId,
  ) async {
    final response = await dio.get(
      '/intelligence/schools/$schoolId/assignments/$assignmentId/terms/$termId/clusters',
    );
    return IntelligenceMapper.snapshotFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<RecalculateStudentClusterSummary> recalculateStudentClusters(
    String schoolId,
    String assignmentId,
    String termId,
  ) async {
    final response = await dio.post(
      '/intelligence/schools/$schoolId/assignments/$assignmentId/terms/$termId/clusters/recalculate',
    );
    return IntelligenceMapper.recalculateSummaryFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
  Future<StudentStatistics> getStudentStatistics(
    String schoolId,
    String studentId,
  ) async {
    final response = await dio.get(
      '/intelligence/schools/$schoolId/students/$studentId/statistics',
    );
    return IntelligenceMapper.studentStatisticsFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}
