import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/licenses/data/mappers/mappers.dart';
import 'package:mobile/features/licenses/domain/domain.dart';

class LicenseApi {
  late final Dio dio;

  LicenseApi({required String accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<List<StudentLicense>> getStudentLicenses(String schoolId, String studentId) async {
    final response = await dio.get('/licenses/schools/$schoolId/students/$studentId');
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(LicenseMapper.licenseFromJson).toList();
  }

  Future<void> createStudentLicense(
    String schoolId,
    String studentId,
    String reason,
    String description,
    String startDate,
    String endDate,
  ) async {
    await dio.post(
      '/licenses/schools/$schoolId/students/$studentId',
      data: {
        'reason': reason,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
  }

  Future<void> updateStudentLicense(
    String schoolId,
    String studentId,
    String licenseId,
    String reason,
    String description,
    String startDate,
    String endDate,
  ) async {
    await dio.put(
      '/licenses/schools/$schoolId/students/$studentId/$licenseId',
      data: {
        'reason': reason,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
  }

  Future<void> deleteStudentLicense(
    String schoolId,
    String studentId,
    String licenseId,
  ) async {
    await dio.delete('/licenses/schools/$schoolId/students/$studentId/$licenseId');
  }
}
