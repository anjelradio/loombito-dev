import 'package:mobile/features/evaluations/data/api/api.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';

class EvaluationRepository {
  final EvaluationApi _evaluationApi;

  EvaluationRepository({required EvaluationApi evaluationApi})
    : _evaluationApi = evaluationApi;

  Future<EvaluationList> getEvaluationsByAssignment(
    String schoolId,
    String assignmentId, {
    int page = 1,
    int perPage = 15,
  }) {
    return _evaluationApi.getEvaluationsByAssignment(
      schoolId,
      assignmentId,
      page: page,
      perPage: perPage,
    );
  }

  Future<List<EvaluationTypeOption>> getEvaluationTypeOptions(String schoolId) {
    return _evaluationApi.getEvaluationTypeOptions(schoolId);
  }

  Future<List<EvaluationTermOption>> getEvaluationTermOptions(String schoolId) {
    return _evaluationApi.getEvaluationTermOptions(schoolId);
  }

  Future<Evaluation> createEvaluation(
    String schoolId,
    String assignmentId,
    String name,
    String description,
    String presentationDate,
    String termId,
    String evaluationTypeId,
  ) {
    return _evaluationApi.createEvaluation(schoolId, {
      'name': name,
      'description': description.isEmpty ? null : description,
      'presentation_date': presentationDate,
      'term_id': termId,
      'assignment_id': assignmentId,
      'evaluation_type_id': evaluationTypeId,
    });
  }

  Future<Evaluation> getEvaluationById(String schoolId, String evaluationId) {
    return _evaluationApi.getEvaluationById(schoolId, evaluationId);
  }

  Future<Evaluation> updateEvaluation(
    String schoolId,
    String evaluationId,
    String name,
    String description,
    String presentationDate,
    String termId,
    String evaluationTypeId,
  ) {
    return _evaluationApi.updateEvaluation(schoolId, evaluationId, {
      'name': name,
      'description': description.isEmpty ? null : description,
      'presentation_date': presentationDate,
      'term_id': termId,
      'evaluation_type_id': evaluationTypeId,
    });
  }

  Future<void> deleteEvaluation(String schoolId, String evaluationId) {
    return _evaluationApi.deleteEvaluation(schoolId, evaluationId);
  }

  Future<List<TermAverageOption>> getTermAverageOptions(String schoolId) {
    return _evaluationApi.getTermAverageOptions(schoolId);
  }

  Future<List<StudentTermAverageRow>> getTermAveragesByAssignment(
    String schoolId,
    String assignmentId,
    String termId,
  ) {
    return _evaluationApi.getTermAveragesByAssignment(
      schoolId,
      assignmentId,
      termId,
    );
  }

  Future<CalculateTermAverageSummary> calculateTermAveragesByAssignment(
    String schoolId,
    String assignmentId,
    String termId,
  ) {
    return _evaluationApi.calculateTermAveragesByAssignment(
      schoolId,
      assignmentId,
      termId,
    );
  }
}
