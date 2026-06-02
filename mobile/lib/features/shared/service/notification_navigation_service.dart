import 'package:flutter/foundation.dart';

final notificationRouteNotifier = ValueNotifier<String?>(null);

class NotificationNavigationService {
  static const String notificationsRoute = '/communications/notifications';

  static void openNotifications() {
    notificationRouteNotifier.value = notificationsRoute;
  }

  static void consume() {
    notificationRouteNotifier.value = null;
  }
}
