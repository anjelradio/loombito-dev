import 'package:mobile/features/communications/domain/domain.dart';

class CommunicationMapper {
  static TeacherCommunicationCourse courseFromJson(Map<String, dynamic> json) {
    return TeacherCommunicationCourse(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  static TeacherCommunicationStudent studentFromJson(Map<String, dynamic> json) {
    return TeacherCommunicationStudent(
      id: (json['id'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
    );
  }

  static StudentCommunication studentCommunicationFromJson(
    Map<String, dynamic> json,
  ) {
    final rawDate = json['created_date']?.toString();
    return StudentCommunication(
      id: (json['id'] ?? '').toString(),
      schoolId: (json['school_id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      createdDate: rawDate == null ? null : DateTime.tryParse(rawDate),
    );
  }

  static CommunicationNotification notificationFromJson(
    Map<String, dynamic> json,
  ) {
    final rawDate = json['created_date']?.toString();
    return CommunicationNotification(
      id: (json['id'] ?? '').toString(),
      schoolId: (json['school_id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      isRead: json['is_read'] == true,
      createdDate: rawDate == null ? null : DateTime.tryParse(rawDate),
    );
  }
}
