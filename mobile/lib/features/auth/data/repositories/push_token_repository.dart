import 'package:mobile/features/auth/data/api/push_token_api.dart';

class PushTokenRepository {
  PushTokenRepository({required PushTokenApi pushTokenApi}) : _pushTokenApi = pushTokenApi;

  final PushTokenApi _pushTokenApi;

  Future<void> registerToken({
    required String accessToken,
    required String token,
    required String platform,
  }) {
    return _pushTokenApi.registerToken(
      accessToken: accessToken,
      token: token,
      platform: platform,
    );
  }
}
