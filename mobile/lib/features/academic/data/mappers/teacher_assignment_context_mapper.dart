import 'package:mobile/features/academic/domain/domain.dart';

class TeacherAssignmentContextMapper {
  static TeacherAssignmentCourseGroup groupJsonToEntity(
    Map<String, dynamic> json,
  ) {
    final subjectsJson = (json['subjects'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return TeacherAssignmentCourseGroup(
      courseId: json['course_id'],
      courseName: json['course_name'],
      subjects: subjectsJson.map(subjectJsonToEntity).toList(),
    );
  }

  static TeacherAssignmentSubject subjectJsonToEntity(
    Map<String, dynamic> json,
  ) {
    return TeacherAssignmentSubject(
      assignmentId: json['assignment_id'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
    );
  }
}
