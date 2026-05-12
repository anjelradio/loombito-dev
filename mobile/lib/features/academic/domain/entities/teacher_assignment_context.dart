class TeacherAssignmentSubject {
  final String assignmentId;
  final String subjectId;
  final String subjectName;

  TeacherAssignmentSubject({
    required this.assignmentId,
    required this.subjectId,
    required this.subjectName,
  });
}

class TeacherAssignmentCourseGroup {
  final String courseId;
  final String courseName;
  final List<TeacherAssignmentSubject> subjects;

  TeacherAssignmentCourseGroup({
    required this.courseId,
    required this.courseName,
    required this.subjects,
  });
}
