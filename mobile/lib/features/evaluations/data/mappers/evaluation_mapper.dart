import 'package:mobile/features/evaluations/domain/domain.dart';

class EvaluationMapper {
  static Evaluation fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      presentationDate: json['presentation_date'],
      termId: json['term_id'],
      termName: json['term_name'],
      assignmentId: json['assignment_id'],
      evaluationTypeId: json['evaluation_type_id'],
      evaluationTypeName: json['evaluation_type_name'],
      schoolId: json['school_id'],
      isClosed: json['is_closed'] ?? false,
    );
  }

  static EvaluationList listFromJson(Map<String, dynamic> json) {
    final evaluationsJson = (json['evaluations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return EvaluationList(
      evaluations: evaluationsJson.map(fromJson).toList(),
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      hasPrev: json['has_prev'] ?? false,
      hasNext: json['has_next'] ?? false,
    );
  }

  static EvaluationTypeOption typeOptionFromJson(Map<String, dynamic> json) {
    return EvaluationTypeOption(id: json['id'], name: json['name']);
  }

  static EvaluationTermOption termOptionFromJson(Map<String, dynamic> json) {
    return EvaluationTermOption(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'] ?? false,
    );
  }

  static TermAverageOption termAverageOptionFromJson(
    Map<String, dynamic> json,
  ) {
    return TermAverageOption(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'] ?? false,
    );
  }

  static StudentTermAverageRow studentTermAverageRowFromJson(
    Map<String, dynamic> json,
  ) {
    return StudentTermAverageRow(
      studentId: json['student_id'].toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      saberScore: (json['saber_score'] as num?)?.toDouble(),
      hacerScore: (json['hacer_score'] as num?)?.toDouble(),
      serScore: (json['ser_score'] as num?)?.toDouble(),
      autoevaluacionScore: (json['autoevaluacion_score'] as num?)?.toDouble(),
      finalScore: (json['final_score'] as num?)?.toDouble(),
      status: (json['status'] ?? '').toString(),
    );
  }

  static CalculateTermAverageSummary calculateTermAverageSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    return CalculateTermAverageSummary(
      processedStudents: (json['processed_students'] as num?)?.toInt() ?? 0,
      assignmentId: json['assignment_id'].toString(),
      termId: json['term_id'].toString(),
    );
  }
}
