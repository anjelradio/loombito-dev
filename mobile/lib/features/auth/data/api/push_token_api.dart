import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';

class PushTokenApi {
  Future<void> registerToken({
    required String accessToken,
    required String token,
    required String platform,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    await dio.post(
      '/communications/push-tokens',
      data: {
        'token': token,
        'platform': platform,
      },
    );
  }
}
