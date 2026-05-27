class LinkedStudent {
  final String id;
  final String firstName;
  final String lastName;
  final String schoolId;
  final String schoolName;
  final String? courseName;

  const LinkedStudent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.schoolId,
    required this.schoolName,
    this.courseName,
  });
}
