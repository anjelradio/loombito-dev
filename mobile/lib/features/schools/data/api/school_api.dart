import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/schools/data/mappers/mappers.dart';
import 'package:mobile/features/schools/domain/domain.dart';

class SchoolApi {
  late final Dio dio;
  final String accessToken;

  SchoolApi({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<List<School>> getSchoolsByUser() async {
    final response = await dio.get('/schools/by_user');
    final List<School> schools = [];
    for (final school in response.data ?? []) {
      schools.add(SchoolMapper.schoolJsonToEntity(school));
    }
    return schools;
  }

  Future<School> joinSchoolByCode(String code) async {
    final response = await dio.post(
      '/schools/join',
      data: {'code': code.trim().toUpperCase()},
    );

    return SchoolMapper.schoolJsonToEntity(response.data);
  }
}
