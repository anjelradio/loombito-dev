import 'package:mobile/features/communications/data/api/api.dart';
import 'package:mobile/features/communications/domain/domain.dart';

class CommunicationRepository {
  final CommunicationApi _communicationApi;

  CommunicationRepository({required CommunicationApi communicationApi})
    : _communicationApi = communicationApi;

  Future<List<TeacherCommunicationCourse>> getTeacherCommunicationCourses(String schoolId) {
    return _communicationApi.getTeacherCommunicationCourses(schoolId);
  }

  Future<List<TeacherCommunicationStudent>> getTeacherCommunicationStudentsByCourse(
    String schoolId,
    String courseId,
  ) {
    return _communicationApi.getTeacherCommunicationStudentsByCourse(schoolId, courseId);
  }

  Future<List<StudentCommunication>> getStudentCommunications(String schoolId, String studentId) {
    return _communicationApi.getStudentCommunications(schoolId, studentId);
  }

  Future<void> createStudentCommunication(
    String schoolId,
    String studentId,
    String title,
    String body,
  ) {
    return _communicationApi.createStudentCommunication(
      schoolId,
      studentId,
      title,
      body,
    );
  }

  Future<void> updateStudentCommunication(
    String schoolId,
    String communicationId,
    String title,
    String body,
  ) {
    return _communicationApi.updateStudentCommunication(
      schoolId,
      communicationId,
      title,
      body,
    );
  }

  Future<void> deleteStudentCommunication(
    String schoolId,
    String communicationId,
  ) {
    return _communicationApi.deleteStudentCommunication(schoolId, communicationId);
  }

  Future<List<CommunicationNotification>> getMyNotifications({
    bool onlyUnread = true,
  }) {
    return _communicationApi.getMyNotifications(onlyUnread: onlyUnread);
  }

  Future<void> markNotificationAsRead(String notificationId) {
    return _communicationApi.markNotificationAsRead(notificationId);
  }
}
