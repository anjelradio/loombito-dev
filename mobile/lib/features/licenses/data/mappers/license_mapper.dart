import 'package:mobile/features/licenses/domain/domain.dart';

class LicenseMapper {
  static StudentLicense licenseFromJson(Map<String, dynamic> json) {
    final rawCreatedDate = json['created_date']?.toString();
    return StudentLicense(
      id: (json['id'] ?? '').toString(),
      schoolId: (json['school_id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      createdDate: rawCreatedDate == null ? null : DateTime.tryParse(rawCreatedDate),
    );
  }
}
