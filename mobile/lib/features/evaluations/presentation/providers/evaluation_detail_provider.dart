import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/evaluations/data/repositories/repositories.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/evaluation_repository_provider.dart';

final evaluationDetailProvider =
    StateNotifierProvider<EvaluationDetailNotifier, EvaluationDetailState>((
      ref,
    ) {
      final repository = ref.watch(evaluationRepositoryProvider);
      return EvaluationDetailNotifier(repository: repository);
    });

class EvaluationDetailNotifier extends StateNotifier<EvaluationDetailState> {
  final EvaluationRepository repository;

  EvaluationDetailNotifier({required this.repository})
    : super(EvaluationDetailState());

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
      final results = await Future.wait([
        repository.getEvaluationById(schoolId, evaluationId),
        repository.getEvaluationTypeOptions(schoolId),
        repository.getEvaluationTermOptions(schoolId),
      ]);

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        evaluation: results[0] as Evaluation,
        typeOptions: results[1] as List<EvaluationTypeOption>,
        termOptions: results[2] as List<EvaluationTermOption>,
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['No se pudo obtener la evaluacion.'],
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

class EvaluationDetailState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String evaluationId;
  final Evaluation? evaluation;
  final List<EvaluationTypeOption> typeOptions;
  final List<EvaluationTermOption> termOptions;
  final List<String> errorMessages;

  EvaluationDetailState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.evaluationId = '',
    this.evaluation,
    this.typeOptions = const [],
    this.termOptions = const [],
    this.errorMessages = const [],
  });

  EvaluationDetailState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? evaluationId,
    Evaluation? evaluation,
    List<EvaluationTypeOption>? typeOptions,
    List<EvaluationTermOption>? termOptions,
    List<String>? errorMessages,
  }) => EvaluationDetailState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    evaluationId: evaluationId ?? this.evaluationId,
    evaluation: evaluation ?? this.evaluation,
    typeOptions: typeOptions ?? this.typeOptions,
    termOptions: termOptions ?? this.termOptions,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
