import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/evaluations/data/repositories/repositories.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/evaluation_repository_provider.dart';

final assignmentEvaluationsProvider =
    StateNotifierProvider<
      AssignmentEvaluationsNotifier,
      AssignmentEvaluationsState
    >((ref) {
      final repository = ref.watch(evaluationRepositoryProvider);
      return AssignmentEvaluationsNotifier(repository: repository);
    });

class AssignmentEvaluationsNotifier
    extends StateNotifier<AssignmentEvaluationsState> {
  final EvaluationRepository repository;

  AssignmentEvaluationsNotifier({required this.repository})
    : super(AssignmentEvaluationsState());

  Future<void> load(
    String schoolId,
    String assignmentId, {
    int page = 1,
    int perPage = 15,
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
      final results = await Future.wait([
        repository.getEvaluationsByAssignment(
          schoolId,
          assignmentId,
          page: page,
          perPage: perPage,
        ),
        repository.getEvaluationTypeOptions(schoolId),
        repository.getEvaluationTermOptions(schoolId),
      ]);

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        evaluations: results[0] as EvaluationList,
        typeOptions: results[1] as List<EvaluationTypeOption>,
        termOptions: results[2] as List<EvaluationTermOption>,
        errorMessages: const [],
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: [_resolveDioError(error)],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexión. Inténtalo nuevamente.'],
      );
    }
  }

  String _resolveDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Error de conexión. Inténtalo nuevamente.';
    }

    return 'No fue posible cargar las evaluaciones.';
  }
}

class AssignmentEvaluationsState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String assignmentId;
  final EvaluationList evaluations;
  final List<EvaluationTypeOption> typeOptions;
  final List<EvaluationTermOption> termOptions;
  final List<String> errorMessages;

  AssignmentEvaluationsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.assignmentId = '',
    EvaluationList? evaluations,
    this.typeOptions = const [],
    this.termOptions = const [],
    this.errorMessages = const [],
  }) : evaluations =
           evaluations ??
           EvaluationList(
             evaluations: const [],
             page: 1,
             perPage: 15,
             totalPages: 0,
             hasPrev: false,
             hasNext: false,
           );

  AssignmentEvaluationsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? assignmentId,
    EvaluationList? evaluations,
    List<EvaluationTypeOption>? typeOptions,
    List<EvaluationTermOption>? termOptions,
    List<String>? errorMessages,
  }) => AssignmentEvaluationsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    assignmentId: assignmentId ?? this.assignmentId,
    evaluations: evaluations ?? this.evaluations,
    typeOptions: typeOptions ?? this.typeOptions,
    termOptions: termOptions ?? this.termOptions,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
