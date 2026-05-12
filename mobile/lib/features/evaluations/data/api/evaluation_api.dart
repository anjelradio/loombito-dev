import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/evaluations/data/mappers/mappers.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';

class EvaluationApi {
  late final Dio dio;
  final String accessToken;

  EvaluationApi({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<EvaluationList> getEvaluationsByAssignment(
    String schoolId,
    String assignmentId, {
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/assignments/$assignmentId/evaluations',
      queryParameters: {'page': page, 'per_page': perPage},
    );

    return EvaluationMapper.listFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<List<EvaluationTypeOption>> getEvaluationTypeOptions(
    String schoolId,
  ) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/evaluation-types',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(EvaluationMapper.typeOptionFromJson).toList();
  }

  Future<List<EvaluationTermOption>> getEvaluationTermOptions(
    String schoolId,
  ) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/term-options',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(EvaluationMapper.termOptionFromJson).toList();
  }

  Future<Evaluation> createEvaluation(
    String schoolId,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.post(
      '/evaluations/schools/$schoolId/evaluations',
      data: payload,
    );

    return EvaluationMapper.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Evaluation> getEvaluationById(
    String schoolId,
    String evaluationId,
  ) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/evaluations/$evaluationId',
    );

    return EvaluationMapper.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Evaluation> updateEvaluation(
    String schoolId,
    String evaluationId,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.put(
      '/evaluations/schools/$schoolId/evaluations/$evaluationId',
      data: payload,
    );

    return EvaluationMapper.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteEvaluation(String schoolId, String evaluationId) async {
    await dio.delete(
      '/evaluations/schools/$schoolId/evaluations/$evaluationId',
    );
  }

  Future<List<TermAverageOption>> getTermAverageOptions(String schoolId) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/term-average-options',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(EvaluationMapper.termAverageOptionFromJson).toList();
  }

  Future<List<StudentTermAverageRow>> getTermAveragesByAssignment(
    String schoolId,
    String assignmentId,
    String termId,
  ) async {
    final response = await dio.get(
      '/evaluations/schools/$schoolId/assignments/$assignmentId/terms/$termId/averages',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(EvaluationMapper.studentTermAverageRowFromJson).toList();
  }

  Future<CalculateTermAverageSummary> calculateTermAveragesByAssignment(
    String schoolId,
    String assignmentId,
    String termId,
  ) async {
    final response = await dio.post(
      '/evaluations/schools/$schoolId/assignments/$assignmentId/terms/$termId/averages/calculate',
    );
    return EvaluationMapper.calculateTermAverageSummaryFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}
