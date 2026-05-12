import 'package:mobile/features/students/data/api/api.dart';
import 'package:mobile/features/students/domain/domain.dart';

class StudentRepository {
  final StudentApi _studentApi;

  StudentRepository({required StudentApi studentApi})
    : _studentApi = studentApi;

  Future<List<StudentGradebookRow>> getGradebookByEvaluation(
    String schoolId,
    String evaluationId,
  ) {
    return _studentApi.getGradebookByEvaluation(schoolId, evaluationId);
  }

  Future<EvaluationFinalizeSummary> finalizeEvaluation(
    String schoolId,
    String evaluationId,
  ) {
    return _studentApi.finalizeEvaluation(schoolId, evaluationId);
  }

  Future<void> upsertEvaluationGrade(
    String schoolId,
    String evaluationId,
    String studentId,
    double score,
    String? observation,
  ) {
    return _studentApi.upsertEvaluationGrade(
      schoolId,
      evaluationId,
      studentId,
      score,
      observation,
    );
  }
}
