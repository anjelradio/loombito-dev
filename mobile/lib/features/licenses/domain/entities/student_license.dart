class StudentLicense {
  final String id;
  final String schoolId;
  final String studentId;
  final String reason;
  final String description;
  final String startDate;
  final String endDate;
  final DateTime? createdDate;

  StudentLicense({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.reason,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdDate,
  });
}
