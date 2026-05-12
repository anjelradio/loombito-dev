import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/attendance/data/mappers/mappers.dart';
import 'package:mobile/features/attendance/domain/domain.dart';

class AttendanceApi {
  late final Dio dio;

  AttendanceApi({required String accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<AttendanceSessionList> getSessionsByAssignment(
    String schoolId,
    String assignmentId, {
    int page = 1,
    int perPage = 8,
  }) async {
    final response = await dio.get(
      '/attendance/schools/$schoolId/assignments/$assignmentId/sessions',
      queryParameters: {'page': page, 'per_page': perPage},
    );

    return AttendanceMapper.listFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AttendanceSession> createAttendanceSession(
    String schoolId,
    String attendanceDate,
    String assignmentId,
  ) async {
    final response = await dio.post(
      '/attendance/schools/$schoolId/sessions',
      data: {'attendance_date': attendanceDate, 'assignment_id': assignmentId},
    );

    return AttendanceMapper.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<AttendanceSession> getSessionById(
    String schoolId,
    String sessionId,
  ) async {
    final response = await dio.get(
      '/attendance/schools/$schoolId/sessions/$sessionId',
    );
    return AttendanceMapper.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<AttendanceStatusOption>> getStatusOptions(String schoolId) async {
    final response = await dio.get(
      '/attendance/schools/$schoolId/status-options',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(AttendanceMapper.statusOptionFromJson).toList();
  }

  Future<List<AttendanceGradebookRow>> getGradebookBySession(
    String schoolId,
    String sessionId,
  ) async {
    final response = await dio.get(
      '/attendance/schools/$schoolId/sessions/$sessionId/gradebook',
    );
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(AttendanceMapper.gradebookRowFromJson).toList();
  }

  Future<AttendanceGradebookRow> upsertRecordBySessionStudent(
    String schoolId,
    String sessionId,
    String studentId,
    String statusId,
  ) async {
    final response = await dio.put(
      '/attendance/schools/$schoolId/sessions/$sessionId/students/$studentId/record',
      data: {'status_id': statusId},
    );
    return AttendanceMapper.gradebookRowFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AttendanceFinalizeSummary> finalizeSession(
    String schoolId,
    String sessionId,
  ) async {
    final response = await dio.post(
      '/attendance/schools/$schoolId/sessions/$sessionId/finalize',
    );
    return AttendanceMapper.finalizeSummaryFromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> deleteSession(String schoolId, String sessionId) async {
    await dio.delete('/attendance/schools/$schoolId/sessions/$sessionId');
  }
}
