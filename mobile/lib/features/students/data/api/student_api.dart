import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/students/data/mappers/mappers.dart';
import 'package:mobile/features/students/domain/domain.dart';

class StudentApi {
  late final Dio dio;
  final String accessToken;

  StudentApi({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<List<StudentGradebookRow>> getGradebookByEvaluation(
    String schoolId,
    String evaluationId,
  ) async {
    final response = await dio.get(
      '/students/schools/$schoolId/evaluations/$evaluationId/gradebook',
    );

    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return rows.map(StudentGradebookMapper.fromJson).toList();
  }

  Future<EvaluationFinalizeSummary> finalizeEvaluation(
    String schoolId,
    String evaluationId,
  ) async {
    final response = await dio.post(
      '/students/schools/$schoolId/evaluations/$evaluationId/finalize',
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    return EvaluationFinalizeSummary(
      createdMissing: (data['created_missing'] as num?)?.toInt() ?? 0,
      totalStudents: (data['total_students'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> upsertEvaluationGrade(
    String schoolId,
    String evaluationId,
    String studentId,
    double score,
    String? observation,
  ) async {
    await dio.put(
      '/students/schools/$schoolId/evaluations/$evaluationId/students/$studentId/grade',
      data: {
        'score': score,
        'observation': (observation == null || observation.trim().isEmpty)
            ? null
            : observation.trim(),
      },
    );
  }
}
