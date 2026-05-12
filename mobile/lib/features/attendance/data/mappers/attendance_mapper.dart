import 'package:mobile/features/attendance/domain/domain.dart';

class AttendanceMapper {
  static AttendanceSession fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      attendanceDate: (json['attendance_date'] ?? '').toString(),
      isClosed: json['is_closed'] == true,
      assignmentId: json['assignment_id'].toString(),
      termId: json['term_id'].toString(),
      termName: (json['term_name'] ?? '').toString(),
      schoolId: json['school_id'].toString(),
    );
  }

  static AttendanceSessionList listFromJson(Map<String, dynamic> json) {
    final rows = (json['sessions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();

    return AttendanceSessionList(
      sessions: rows,
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 8,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      hasPrev: json['has_prev'] == true,
      hasNext: json['has_next'] == true,
    );
  }

  static AttendanceStatusOption statusOptionFromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceStatusOption(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  static AttendanceGradebookRow gradebookRowFromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceGradebookRow(
      studentId: json['student_id'].toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      attendanceRecordId: json['attendance_record_id']?.toString(),
      statusId: json['status_id']?.toString(),
      statusName: json['status_name']?.toString(),
      observation: json['observation']?.toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  static AttendanceFinalizeSummary finalizeSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceFinalizeSummary(
      createdMissing: (json['created_missing'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
    );
  }
}
