import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/communications/data/mappers/mappers.dart';
import 'package:mobile/features/communications/domain/domain.dart';

class CommunicationApi {
  late final Dio dio;

  CommunicationApi({required String accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<List<TeacherCommunicationCourse>> getTeacherCommunicationCourses(
    String schoolId,
  ) async {
    final response = await dio.get('/communications/teacher/schools/$schoolId/courses');
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(CommunicationMapper.courseFromJson).toList();
  }

  Future<List<TeacherCommunicationStudent>> getTeacherCommunicationStudentsByCourse(
    String schoolId,
    String courseId,
  ) async {
    final response = await dio.get('/communications/teacher/schools/$schoolId/courses/$courseId/students');
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(CommunicationMapper.studentFromJson).toList();
  }

  Future<List<StudentCommunication>> getStudentCommunications(
    String schoolId,
    String studentId,
  ) async {
    final response = await dio.get('/communications/schools/$schoolId/students/$studentId/communications');
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(CommunicationMapper.studentCommunicationFromJson).toList();
  }

  Future<void> createStudentCommunication(
    String schoolId,
    String studentId,
    String title,
    String body,
  ) async {
    await dio.post(
      '/communications/schools/$schoolId/students/$studentId/communications',
      data: {'title': title, 'body': body},
    );
  }

  Future<void> updateStudentCommunication(
    String schoolId,
    String communicationId,
    String title,
    String body,
  ) async {
    await dio.put(
      '/communications/schools/$schoolId/communications/$communicationId',
      data: {'title': title, 'body': body},
    );
  }

  Future<void> deleteStudentCommunication(
    String schoolId,
    String communicationId,
  ) async {
    await dio.delete('/communications/schools/$schoolId/communications/$communicationId');
  }

  Future<List<CommunicationNotification>> getMyNotifications({
    bool onlyUnread = true,
  }) async {
    final response = await dio.get(
      '/communications/notifications',
      queryParameters: {'only_unread': onlyUnread},
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(CommunicationMapper.notificationFromJson).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await dio.patch('/communications/notifications/$notificationId/read');
  }
}
