import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/communications/data/repositories/repositories.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/communication_repository_provider.dart';

final studentCommunicationsProvider =
    StateNotifierProvider<StudentCommunicationsNotifier, StudentCommunicationsState>((ref) {
      final repository = ref.watch(communicationRepositoryProvider);
      return StudentCommunicationsNotifier(repository: repository);
    });

class StudentCommunicationsNotifier extends StateNotifier<StudentCommunicationsState> {
  final CommunicationRepository repository;

  StudentCommunicationsNotifier({required this.repository}) : super(StudentCommunicationsState());

  Future<void> load(String schoolId, String studentId, {bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.hasLoaded && state.schoolId == schoolId && state.studentId == studentId) return;

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      studentId: studentId,
      errorMessages: const [],
    );

    try {
      final communications = await repository.getStudentCommunications(schoolId, studentId);
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        communications: communications,
        errorMessages: const [],
      );
    } on DioException catch (error) {
      state = state.copyWith(isLoading: false, hasLoaded: true, errorMessages: [_resolveError(error)]);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexion. Intentalo nuevamente.'],
      );
    }
  }

  String _resolveError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Error de conexion. Intentalo nuevamente.';
    }
    return 'No fue posible cargar los comunicados del estudiante.';
  }
}

class StudentCommunicationsState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String studentId;
  final List<StudentCommunication> communications;
  final List<String> errorMessages;

  StudentCommunicationsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.studentId = '',
    this.communications = const [],
    this.errorMessages = const [],
  });

  StudentCommunicationsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? studentId,
    List<StudentCommunication>? communications,
    List<String>? errorMessages,
  }) => StudentCommunicationsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    communications: communications ?? this.communications,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
