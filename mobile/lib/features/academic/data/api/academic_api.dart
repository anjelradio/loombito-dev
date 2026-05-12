import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/academic/data/mappers/mappers.dart';
import 'package:mobile/features/academic/domain/domain.dart';

class AcademicApi {
  late final Dio dio;
  final String accessToken;

  AcademicApi({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<List<TeacherAssignmentCourseGroup>> getTeacherAssignmentGroups(
    String schoolId,
  ) async {
    final response = await dio.get(
      '/academic/schools/$schoolId/teacher/assignment-groups',
    );

    final groupsJson = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return groupsJson
        .map(TeacherAssignmentContextMapper.groupJsonToEntity)
        .toList();
  }
}
