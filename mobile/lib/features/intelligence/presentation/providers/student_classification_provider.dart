import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/intelligence/data/data.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';
import 'package:mobile/features/intelligence/presentation/providers/intelligence_repository_provider.dart';

final studentClassificationProvider =
    StateNotifierProvider<
      StudentClassificationNotifier,
      StudentClassificationState
    >((ref) {
      final repository = ref.watch(intelligenceRepositoryProvider);
      return StudentClassificationNotifier(repository: repository);
    });

class StudentClassificationNotifier
    extends StateNotifier<StudentClassificationState> {
  final IntelligenceRepository repository;

  StudentClassificationNotifier({required this.repository})
    : super(StudentClassificationState());

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
      final options = await repository.getTermOptions(schoolId);
      IntelligenceTermOption? active;
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

      final snapshot = selected.id.isEmpty
          ? null
          : await repository.getStudentClusters(
              schoolId,
              assignmentId,
              selected.id,
            );

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        termOptions: options,
        selectedTermId: selected.id,
        snapshot: snapshot,
        errorMessages: const [],
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['No fue posible cargar la clasificacion.'],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexion. Intentalo nuevamente.'],
      );
    }
  }

  Future<RecalculateStudentClusterSummary?> recalculateSelectedTerm() async {
    final schoolId = state.schoolId;
    final assignmentId = state.assignmentId;
    final termId = state.selectedTermId;
    if (schoolId.isEmpty || assignmentId.isEmpty || termId.isEmpty) return null;

    state = state.copyWith(isCalculating: true, errorMessages: const []);
    try {
      final summary = await repository.recalculateStudentClusters(
        schoolId,
        assignmentId,
        termId,
      );
      final snapshot = await repository.getStudentClusters(
        schoolId,
        assignmentId,
        termId,
      );
      state = state.copyWith(
        isCalculating: false,
        snapshot: snapshot,
        errorMessages: const [],
      );
      return summary;
    } on DioException catch (_) {
      state = state.copyWith(
        isCalculating: false,
        errorMessages: const ['No se pudo calcular la clasificacion.'],
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isCalculating: false,
        errorMessages: const ['No se pudo calcular la clasificacion.'],
      );
      return null;
    }
  }
}

final _emptyTerm = IntelligenceTermOption(id: '', name: '', isActive: false);

class StudentClassificationState {
  final bool isLoading;
  final bool isCalculating;
  final bool hasLoaded;
  final String schoolId;
  final String assignmentId;
  final List<IntelligenceTermOption> termOptions;
  final String selectedTermId;
  final StudentClusterSnapshot? snapshot;
  final List<String> errorMessages;

  StudentClassificationState({
    this.isLoading = false,
    this.isCalculating = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.assignmentId = '',
    this.termOptions = const [],
    this.selectedTermId = '',
    this.snapshot,
    this.errorMessages = const [],
  });

  IntelligenceTermOption? get selectedTerm {
    for (final option in termOptions) {
      if (option.id == selectedTermId) return option;
    }
    return null;
  }

  StudentClassificationState copyWith({
    bool? isLoading,
    bool? isCalculating,
    bool? hasLoaded,
    String? schoolId,
    String? assignmentId,
    List<IntelligenceTermOption>? termOptions,
    String? selectedTermId,
    StudentClusterSnapshot? snapshot,
    List<String>? errorMessages,
  }) => StudentClassificationState(
    isLoading: isLoading ?? this.isLoading,
    isCalculating: isCalculating ?? this.isCalculating,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    assignmentId: assignmentId ?? this.assignmentId,
    termOptions: termOptions ?? this.termOptions,
    selectedTermId: selectedTermId ?? this.selectedTermId,
    snapshot: snapshot ?? this.snapshot,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
