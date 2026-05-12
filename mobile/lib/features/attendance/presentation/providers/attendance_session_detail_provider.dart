import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/attendance/data/repositories/repositories.dart';
import 'package:mobile/features/attendance/domain/domain.dart';
import 'package:mobile/features/attendance/presentation/providers/attendance_repository_provider.dart';

final attendanceSessionDetailProvider =
    StateNotifierProvider<
      AttendanceSessionDetailNotifier,
      AttendanceSessionDetailState
    >((ref) {
      final repository = ref.watch(attendanceRepositoryProvider);
      return AttendanceSessionDetailNotifier(repository: repository);
    });

class AttendanceSessionDetailNotifier
    extends StateNotifier<AttendanceSessionDetailState> {
  final AttendanceRepository repository;

  AttendanceSessionDetailNotifier({required this.repository})
    : super(AttendanceSessionDetailState());

  Future<void> load(
    String schoolId,
    String sessionId, {
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;
    if (!forceRefresh &&
        state.hasLoaded &&
        state.schoolId == schoolId &&
        state.sessionId == sessionId) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      sessionId: sessionId,
      errorMessages: const [],
    );

    try {
      final results = await Future.wait([
        repository.getSessionById(schoolId, sessionId),
        repository.getStatusOptions(schoolId),
        repository.getGradebookBySession(schoolId, sessionId),
      ]);
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        session: results[0] as AttendanceSession,
        statusOptions: results[1] as List<AttendanceStatusOption>,
        rows: results[2] as List<AttendanceGradebookRow>,
        errorMessages: const [],
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['No fue posible cargar la sesion de asistencia.'],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexión. Inténtalo nuevamente.'],
      );
    }
  }

  Future<bool> markStudentStatus(String studentId, String statusId) async {
    final schoolId = state.schoolId;
    final sessionId = state.sessionId;
    if (schoolId.isEmpty || sessionId.isEmpty) return false;

    final key = '$studentId:$statusId';
    state = state.copyWith(pendingKey: key, errorMessages: const []);

    try {
      final row = await repository.upsertRecordBySessionStudent(
        schoolId,
        sessionId,
        studentId,
        statusId,
      );

      final updatedRows = state.rows
          .map((item) => item.studentId == studentId ? row : item)
          .toList();

      state = state.copyWith(rows: updatedRows, pendingKey: null);
      return true;
    } on DioException catch (_) {
      state = state.copyWith(
        pendingKey: null,
        errorMessages: const ['No se pudo registrar la asistencia.'],
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        pendingKey: null,
        errorMessages: const ['No se pudo registrar la asistencia.'],
      );
      return false;
    }
  }
}

class AttendanceSessionDetailState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String sessionId;
  final AttendanceSession? session;
  final List<AttendanceStatusOption> statusOptions;
  final List<AttendanceGradebookRow> rows;
  final String? pendingKey;
  final List<String> errorMessages;

  AttendanceSessionDetailState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.sessionId = '',
    this.session,
    this.statusOptions = const [],
    this.rows = const [],
    this.pendingKey,
    this.errorMessages = const [],
  });

  AttendanceSessionDetailState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? sessionId,
    AttendanceSession? session,
    List<AttendanceStatusOption>? statusOptions,
    List<AttendanceGradebookRow>? rows,
    String? pendingKey,
    List<String>? errorMessages,
  }) => AttendanceSessionDetailState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    sessionId: sessionId ?? this.sessionId,
    session: session ?? this.session,
    statusOptions: statusOptions ?? this.statusOptions,
    rows: rows ?? this.rows,
    pendingKey: pendingKey,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
