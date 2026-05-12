class AttendanceSession {
  final String id;
  final String name;
  final String attendanceDate;
  final bool isClosed;
  final String assignmentId;
  final String termId;
  final String termName;
  final String schoolId;

  AttendanceSession({
    required this.id,
    required this.name,
    required this.attendanceDate,
    required this.isClosed,
    required this.assignmentId,
    required this.termId,
    required this.termName,
    required this.schoolId,
  });
}

class AttendanceSessionList {
  final List<AttendanceSession> sessions;
  final int page;
  final int perPage;
  final int totalPages;
  final bool hasPrev;
  final bool hasNext;

  AttendanceSessionList({
    required this.sessions,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.hasPrev,
    required this.hasNext,
  });
}

class AttendanceStatusOption {
  final String id;
  final String name;

  AttendanceStatusOption({required this.id, required this.name});
}

class AttendanceGradebookRow {
  final String studentId;
  final String firstName;
  final String lastName;
  final String? attendanceRecordId;
  final String? statusId;
  final String? statusName;
  final String? observation;
  final String status;

  AttendanceGradebookRow({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.attendanceRecordId,
    required this.statusId,
    required this.statusName,
    required this.observation,
    required this.status,
  });
}

class AttendanceFinalizeSummary {
  final int createdMissing;
  final int totalStudents;

  AttendanceFinalizeSummary({
    required this.createdMissing,
    required this.totalStudents,
  });
}
