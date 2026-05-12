import 'package:mobile/features/students/domain/domain.dart';

class StudentGradebookMapper {
  static StudentGradebookRow fromJson(Map<String, dynamic> json) {
    return StudentGradebookRow(
      studentId: json['student_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      score: (json['score'] as num?)?.toDouble(),
      observation: json['observation'],
      evaluationGradeId: json['evaluation_grade_id'],
      status: json['status'],
    );
  }
}
