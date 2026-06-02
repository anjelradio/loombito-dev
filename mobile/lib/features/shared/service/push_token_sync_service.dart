import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';

import 'key_value_storage_service.dart';
import 'key_value_storage_service_impl.dart';

class PushTokenSyncService {
  static const String _authTokenKey = 'token';
  static const String _fcmTokenKey = 'fcm_token';

  final KeyValueStorageService _storage;

  PushTokenSyncService({KeyValueStorageService? storage})
      : _storage = storage ?? KeyValueStorageServiceImpl();

  Future<void> syncStoredToken() async {
    final accessToken = await _storage.getValue<String>(_authTokenKey);
    final fcmToken = await _storage.getValue<String>(_fcmTokenKey);
    if (accessToken == null || accessToken.isEmpty) return;
    if (fcmToken == null || fcmToken.isEmpty) return;

    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    try {
      await dio.post(
        '/communications/push-tokens',
        data: {
          'token': fcmToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
    } on DioException {
      // Best effort: no bloqueamos login si el registro del token falla.
    }
  }
}
