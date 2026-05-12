import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/attendance/data/repositories/repositories.dart';
import 'package:mobile/features/attendance/domain/domain.dart';
import 'package:mobile/features/attendance/presentation/providers/attendance_repository_provider.dart';

final assignmentAttendanceProvider =
    StateNotifierProvider<
      AssignmentAttendanceNotifier,
      AssignmentAttendanceState
    >((ref) {
      final repository = ref.watch(attendanceRepositoryProvider);
      return AssignmentAttendanceNotifier(repository: repository);
    });

class AssignmentAttendanceNotifier
    extends StateNotifier<AssignmentAttendanceState> {
  final AttendanceRepository repository;

  AssignmentAttendanceNotifier({required this.repository})
    : super(AssignmentAttendanceState());

  Future<void> load(
    String schoolId,
    String assignmentId, {
    int page = 1,
    int perPage = 8,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;
    if (!forceRefresh &&
        state.hasLoaded &&
        state.schoolId == schoolId &&
        state.assignmentId == assignmentId) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      assignmentId: assignmentId,
      errorMessages: const [],
    );

    try {
      final sessions = await repository.getSessionsByAssignment(
        schoolId,
        assignmentId,
        page: page,
        perPage: perPage,
      );
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        sessions: sessions,
        errorMessages: const [],
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['No fue posible cargar las asistencias.'],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexión. Inténtalo nuevamente.'],
      );
    }
  }
}

class AssignmentAttendanceState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String assignmentId;
  final AttendanceSessionList sessions;
  final List<String> errorMessages;

  AssignmentAttendanceState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.assignmentId = '',
    AttendanceSessionList? sessions,
    this.errorMessages = const [],
  }) : sessions =
           sessions ??
           AttendanceSessionList(
             sessions: const [],
             page: 1,
             perPage: 8,
             totalPages: 0,
             hasPrev: false,
             hasNext: false,
           );

  AssignmentAttendanceState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? assignmentId,
    AttendanceSessionList? sessions,
    List<String>? errorMessages,
  }) => AssignmentAttendanceState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    assignmentId: assignmentId ?? this.assignmentId,
    sessions: sessions ?? this.sessions,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
