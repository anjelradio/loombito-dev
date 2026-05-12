import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/students/data/repositories/repositories.dart';
import 'package:mobile/features/students/domain/domain.dart';
import 'package:mobile/features/students/presentation/providers/student_repository_provider.dart';

final evaluationGradebookProvider =
    StateNotifierProvider<
      EvaluationGradebookNotifier,
      EvaluationGradebookState
    >((ref) {
      final repository = ref.watch(studentRepositoryProvider);
      return EvaluationGradebookNotifier(repository: repository);
    });

class EvaluationGradebookNotifier
    extends StateNotifier<EvaluationGradebookState> {
  final StudentRepository repository;

  EvaluationGradebookNotifier({required this.repository})
    : super(EvaluationGradebookState());

  Future<void> load(
    String schoolId,
    String evaluationId, {
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;
    if (!forceRefresh &&
        state.hasLoaded &&
        state.schoolId == schoolId &&
        state.evaluationId == evaluationId) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      evaluationId: evaluationId,
      errorMessages: const [],
    );

    try {
      final rows = await repository.getGradebookByEvaluation(
        schoolId,
        evaluationId,
      );
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        rows: rows,
        errorMessages: const [],
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['No se pudieron obtener los estudiantes.'],
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

class EvaluationGradebookState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String evaluationId;
  final List<StudentGradebookRow> rows;
  final List<String> errorMessages;

  EvaluationGradebookState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.evaluationId = '',
    this.rows = const [],
    this.errorMessages = const [],
  });

  EvaluationGradebookState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? evaluationId,
    List<StudentGradebookRow>? rows,
    List<String>? errorMessages,
  }) => EvaluationGradebookState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    evaluationId: evaluationId ?? this.evaluationId,
    rows: rows ?? this.rows,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
