import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';

class ReportsApi {
  late final Dio dio;

  ReportsApi({required String accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
          responseType: ResponseType.bytes,
        ),
      );

  Future<List<int>> exportClusterReportFromAudio({
    required String schoolId,
    required String assignmentId,
    required String termId,
    required String audioPath,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioPath, filename: 'audio.wav'),
    });

    final response = await dio.post(
      '/reports/schools/$schoolId/assignments/$assignmentId/terms/$termId/export/cluster-from-audio',
      data: formData,
    );

    return List<int>.from(response.data);
  }
  Future<List<int>> exportStudentBoletinForParent({
    required String studentId,
  }) async {
    final response = await dio.post(
      '/reports/parents/students/$studentId/export/boletin',
    );

    return List<int>.from(response.data);
  }
}
