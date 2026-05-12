import 'package:mobile/features/schools/data/api/api.dart';
import 'package:mobile/features/schools/domain/domain.dart';

class SchoolRepository {
  SchoolRepository({required SchoolApi schoolApi}) : _schoolApi = schoolApi;
  final SchoolApi _schoolApi;

  Future<List<School>> getSchoolsByUser() {
    return _schoolApi.getSchoolsByUser();
  }

  Future<School> joinSchoolByCode(String code) {
    return _schoolApi.joinSchoolByCode(code);
  }
}
