import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/evaluations/data/repositories/repositories.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/evaluation_repository_provider.dart';

final termAveragesProvider =
    StateNotifierProvider<TermAveragesNotifier, TermAveragesState>((ref) {
      final repository = ref.watch(evaluationRepositoryProvider);
      return TermAveragesNotifier(repository: repository);
    });

class TermAveragesNotifier extends StateNotifier<TermAveragesState> {
  final EvaluationRepository repository;

  TermAveragesNotifier({required this.repository}) : super(TermAveragesState());

  Future<void> load(
    String schoolId,
    String assignmentId, {
    String? selectedTermId,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;
    if (!forceRefresh &&
        state.hasLoaded &&
        state.schoolId == schoolId &&
        state.assignmentId == assignmentId &&
        (selectedTermId == null || selectedTermId == state.selectedTermId)) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      assignmentId: assignmentId,
      errorMessages: const [],
    );

    try {
      final options = await repository.getTermAverageOptions(schoolId);
      TermAverageOption? active;
      for (final option in options) {
        if (option.isActive) {
          active = option;
          break;
        }
      }
      final selected = options.firstWhere(
        (o) => o.id == selectedTermId,
        orElse: () =>
            active ?? (options.isNotEmpty ? options.first : _emptyTerm),
      );

      final rows = selected.id.isEmpty
          ? <StudentTermAverageRow>[]
          : await repository.getTermAveragesByAssignment(
              schoolId,
              assignmentId,
              selected.id,
            );

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        termOptions: options,
        selectedTermId: selected.id,
        rows: rows,
        errorMessages: const [],
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['No fue posible cargar los promedios.'],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexión. Inténtalo nuevamente.'],
      );
    }
  }

  Future<CalculateTermAverageSummary?> calculateSelectedTerm() async {
    final schoolId = state.schoolId;
    final assignmentId = state.assignmentId;
    final termId = state.selectedTermId;
    if (schoolId.isEmpty || assignmentId.isEmpty || termId.isEmpty) return null;

    state = state.copyWith(isCalculating: true, errorMessages: const []);
    try {
      final summary = await repository.calculateTermAveragesByAssignment(
        schoolId,
        assignmentId,
        termId,
      );
      final rows = await repository.getTermAveragesByAssignment(
        schoolId,
        assignmentId,
        termId,
      );
      state = state.copyWith(
        isCalculating: false,
        rows: rows,
        errorMessages: const [],
      );
      return summary;
    } on DioException catch (_) {
      state = state.copyWith(
        isCalculating: false,
        errorMessages: const ['No se pudieron calcular los promedios.'],
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isCalculating: false,
        errorMessages: const ['No se pudieron calcular los promedios.'],
      );
      return null;
    }
  }
}

final _emptyTerm = TermAverageOption(
  id: '',
  name: '',
  startDate: '',
  endDate: '',
  isActive: false,
);

class TermAveragesState {
  final bool isLoading;
  final bool isCalculating;
  final bool hasLoaded;
  final String schoolId;
  final String assignmentId;
  final List<TermAverageOption> termOptions;
  final String selectedTermId;
  final List<StudentTermAverageRow> rows;
  final List<String> errorMessages;

  TermAveragesState({
    this.isLoading = false,
    this.isCalculating = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.assignmentId = '',
    this.termOptions = const [],
    this.selectedTermId = '',
    this.rows = const [],
    this.errorMessages = const [],
  });

  TermAverageOption? get selectedTerm {
    for (final option in termOptions) {
      if (option.id == selectedTermId) return option;
    }
    return null;
  }

  TermAveragesState copyWith({
    bool? isLoading,
    bool? isCalculating,
    bool? hasLoaded,
    String? schoolId,
    String? assignmentId,
    List<TermAverageOption>? termOptions,
    String? selectedTermId,
    List<StudentTermAverageRow>? rows,
    List<String>? errorMessages,
  }) => TermAveragesState(
    isLoading: isLoading ?? this.isLoading,
    isCalculating: isCalculating ?? this.isCalculating,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    assignmentId: assignmentId ?? this.assignmentId,
    termOptions: termOptions ?? this.termOptions,
    selectedTermId: selectedTermId ?? this.selectedTermId,
    rows: rows ?? this.rows,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
