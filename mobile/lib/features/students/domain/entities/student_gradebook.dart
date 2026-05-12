class StudentGradebookRow {
  final String studentId;
  final String firstName;
  final String lastName;
  final double? score;
  final String? observation;
  final String? evaluationGradeId;
  final String status;

  StudentGradebookRow({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.score,
    required this.observation,
    required this.evaluationGradeId,
    required this.status,
  });
}
