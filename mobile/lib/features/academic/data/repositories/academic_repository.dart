import 'package:mobile/features/academic/data/api/api.dart';
import 'package:mobile/features/academic/domain/domain.dart';

class AcademicRepository {
  AcademicRepository({required AcademicApi academicApi})
    : _academicApi = academicApi;

  final AcademicApi _academicApi;

  Future<List<TeacherAssignmentCourseGroup>> getTeacherAssignmentGroups(
    String schoolId,
  ) {
    return _academicApi.getTeacherAssignmentGroups(schoolId);
  }
}
