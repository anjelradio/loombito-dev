import 'package:mobile/features/licenses/data/api/api.dart';
import 'package:mobile/features/licenses/domain/domain.dart';

class LicenseRepository {
  final LicenseApi _licenseApi;

  LicenseRepository({required LicenseApi licenseApi}) : _licenseApi = licenseApi;

  Future<List<StudentLicense>> getStudentLicenses(String schoolId, String studentId) {
    return _licenseApi.getStudentLicenses(schoolId, studentId);
  }

  Future<void> createStudentLicense(
    String schoolId,
    String studentId,
    String reason,
    String description,
    String startDate,
    String endDate,
  ) {
    return _licenseApi.createStudentLicense(
      schoolId,
      studentId,
      reason,
      description,
      startDate,
      endDate,
    );
  }
}
