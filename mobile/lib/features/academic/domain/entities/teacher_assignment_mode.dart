enum TeacherAssignmentMode { evaluations, attendance, averages }

extension TeacherAssignmentModeX on TeacherAssignmentMode {
  String get routeSegment {
    switch (this) {
      case TeacherAssignmentMode.evaluations:
        return 'evaluaciones';
      case TeacherAssignmentMode.attendance:
        return 'asistencias';
      case TeacherAssignmentMode.averages:
        return 'promedios';
    }
  }

  String get title {
    switch (this) {
      case TeacherAssignmentMode.evaluations:
        return 'Evaluaciones';
      case TeacherAssignmentMode.attendance:
        return 'Asistencias';
      case TeacherAssignmentMode.averages:
        return 'Promedios';
    }
  }
}
