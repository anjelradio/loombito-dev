enum TeacherAssignmentMode { evaluations, attendance, averages, classification }

extension TeacherAssignmentModeX on TeacherAssignmentMode {
  String get routeSegment {
    switch (this) {
      case TeacherAssignmentMode.evaluations:
        return 'evaluaciones';
      case TeacherAssignmentMode.attendance:
        return 'asistencias';
      case TeacherAssignmentMode.averages:
        return 'promedios';
      case TeacherAssignmentMode.classification:
        return 'clasificacion';
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
      case TeacherAssignmentMode.classification:
        return 'Clasificacion';
    }
  }
}
