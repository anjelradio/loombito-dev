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

  Future<LinkedStudent> joinStudentByCode(String code) async {
    final response = await dio.post(
      '/students/join',
      data: {'code': code.trim().toUpperCase()},
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    return LinkedStudent(
      id: data['id'] as String,
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      schoolId: data['school_id'] as String? ?? '',
      schoolName: data['school_name'] as String? ?? '',
      courseName: data['course_name'] as String?,
    );
  }

  Future<List<LinkedStudent>> getStudentsByUser() async {
    final response = await dio.get('/students/by_user');
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return rows
        .map(
          (data) => LinkedStudent(
            id: data['id'] as String,
            firstName: data['first_name'] as String? ?? '',
            lastName: data['last_name'] as String? ?? '',
            schoolId: data['school_id'] as String? ?? '',
            schoolName: data['school_name'] as String? ?? '',
            courseName: data['course_name'] as String?,
          ),
        )
        .toList();
  }
}
