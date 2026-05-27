class StudentCommunication {
  final String id;
  final String schoolId;
  final String studentId;
  final String title;
  final String body;
  final DateTime? createdDate;

  StudentCommunication({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.title,
    required this.body,
    required this.createdDate,
  });
}

class CommunicationNotification {
  final String id;
  final String schoolId;
  final String studentId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdDate;

  CommunicationNotification({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdDate,
  });
}
