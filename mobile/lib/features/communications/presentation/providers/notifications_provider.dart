import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/communications/data/repositories/repositories.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/communication_repository_provider.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      final repository = ref.watch(communicationRepositoryProvider);
      return NotificationsNotifier(repository: repository);
    });

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final CommunicationRepository repository;

  NotificationsNotifier({required this.repository}) : super(NotificationsState());

  Future<void> load({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.hasLoaded) return;

    state = state.copyWith(isLoading: true, errorMessages: const []);
    try {
      final notifications = await repository.getMyNotifications(onlyUnread: true);
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        notifications: notifications,
        errorMessages: const [],
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: [_resolveError(error)],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexion. Intentalo nuevamente.'],
      );
    }
  }

  Future<void> markAsReadLocally(String notificationId) async {
    final current = state.notifications;
    final index = current.indexWhere((item) => item.id == notificationId);
    if (index < 0) return;

    final updated = List<CommunicationNotification>.from(current);
    final item = updated[index];
    updated[index] = CommunicationNotification(
      id: item.id,
      schoolId: item.schoolId,
      studentId: item.studentId,
      title: item.title,
      body: item.body,
      isRead: true,
      createdDate: item.createdDate,
    );
    state = state.copyWith(notifications: updated);

    await repository.markNotificationAsRead(notificationId);
  }

  String _resolveError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Error de conexion. Intentalo nuevamente.';
    }
    return 'No fue posible cargar las notificaciones.';
  }
}

class NotificationsState {
  final bool isLoading;
  final bool hasLoaded;
  final List<CommunicationNotification> notifications;
  final List<String> errorMessages;

  NotificationsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.notifications = const [],
    this.errorMessages = const [],
  });

  NotificationsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<CommunicationNotification>? notifications,
    List<String>? errorMessages,
  }) => NotificationsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    notifications: notifications ?? this.notifications,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
