import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'key_value_storage_service.dart';
import 'key_value_storage_service_impl.dart';
import 'push_token_sync_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op for now. The backend will send notification payloads later.
}

class FirebaseMessagingService {
  static const String _tokenKey = 'fcm_token';

  final KeyValueStorageService _storage;
  final PushTokenSyncService _pushTokenSyncService;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  FirebaseMessagingService({KeyValueStorageService? storage})
      : _storage = storage ?? KeyValueStorageServiceImpl(),
        _pushTokenSyncService = PushTokenSyncService(storage: storage);

  Future<String?> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) {
      await _storage.setKeyValue<String>(_tokenKey, token);
    }

    await _pushTokenSyncService.syncStoredToken();

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((newToken) async {
      await _storage.setKeyValue<String>(_tokenKey, newToken);
      await _pushTokenSyncService.syncStoredToken();
    });

    await _onMessageSubscription?.cancel();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((_) {
      // The backend will decide which payload to show; keep this as a hook.
    });

    await _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((_) {});

    return token;
  }

  Future<String?> getStoredToken() {
    return _storage.getValue<String>(_tokenKey);
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();
  }
}
