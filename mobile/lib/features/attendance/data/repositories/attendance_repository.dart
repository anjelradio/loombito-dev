import 'package:mobile/features/attendance/data/api/api.dart';
import 'package:mobile/features/attendance/domain/domain.dart';

class AttendanceRepository {
  final AttendanceApi _attendanceApi;

  AttendanceRepository({required AttendanceApi attendanceApi})
    : _attendanceApi = attendanceApi;

  Future<AttendanceSessionList> getSessionsByAssignment(
    String schoolId,
    String assignmentId, {
    int page = 1,
    int perPage = 8,
  }) {
    return _attendanceApi.getSessionsByAssignment(
      schoolId,
      assignmentId,
      page: page,
      perPage: perPage,
    );
  }

  Future<AttendanceSession> createAttendanceSession(
    String schoolId,
    String attendanceDate,
    String assignmentId,
  ) {
    return _attendanceApi.createAttendanceSession(
      schoolId,
      attendanceDate,
      assignmentId,
    );
  }

  Future<AttendanceSession> getSessionById(String schoolId, String sessionId) {
    return _attendanceApi.getSessionById(schoolId, sessionId);
  }

  Future<List<AttendanceStatusOption>> getStatusOptions(String schoolId) {
    return _attendanceApi.getStatusOptions(schoolId);
  }

  Future<List<AttendanceGradebookRow>> getGradebookBySession(
    String schoolId,
    String sessionId,
  ) {
    return _attendanceApi.getGradebookBySession(schoolId, sessionId);
  }

  Future<AttendanceGradebookRow> upsertRecordBySessionStudent(
    String schoolId,
    String sessionId,
    String studentId,
    String statusId,
  ) {
    return _attendanceApi.upsertRecordBySessionStudent(
      schoolId,
      sessionId,
      studentId,
      statusId,
    );
  }

  Future<AttendanceFinalizeSummary> finalizeSession(
    String schoolId,
    String sessionId,
  ) {
    return _attendanceApi.finalizeSession(schoolId, sessionId);
  }

  Future<void> deleteSession(String schoolId, String sessionId) {
    return _attendanceApi.deleteSession(schoolId, sessionId);
  }
}
