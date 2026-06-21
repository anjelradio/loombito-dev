import 'package:mobile/features/reports/data/api/api.dart';

class ReportsRepository {
  final ReportsApi _api;

  ReportsRepository({required ReportsApi api}) : _api = api;

  Future<List<int>> exportClusterReportFromAudio({
    required String schoolId,
    required String assignmentId,
    required String termId,
    required String audioPath,
  }) {
    return _api.exportClusterReportFromAudio(
      schoolId: schoolId,
      assignmentId: assignmentId,
      termId: termId,
      audioPath: audioPath,
    );
  }
  Future<List<int>> exportStudentBoletinForParent({
    required String studentId,
  }) {
    return _api.exportStudentBoletinForParent(studentId: studentId);
  }
}
