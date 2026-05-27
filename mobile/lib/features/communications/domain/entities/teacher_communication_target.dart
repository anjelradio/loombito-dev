class TeacherCommunicationCourse {
  final String id;
  final String name;

  TeacherCommunicationCourse({required this.id, required this.name});
}

class TeacherCommunicationStudent {
  final String id;
  final String firstName;
  final String lastName;

  TeacherCommunicationStudent({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$lastName $firstName';
}
