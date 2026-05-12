import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/academic/domain/domain.dart';
import 'package:mobile/features/academic/presentation/providers/academic_repository_provider.dart';
import 'package:mobile/features/academic/data/repositories/repositories.dart';

final teacherAssignmentsProvider =
    StateNotifierProvider<TeacherAssignmentsNotifier, TeacherAssignmentsState>((
      ref,
    ) {
      final academicRepository = ref.watch(academicRepositoryProvider);
      return TeacherAssignmentsNotifier(academicRepository: academicRepository);
    });

class TeacherAssignmentsNotifier
    extends StateNotifier<TeacherAssignmentsState> {
  final AcademicRepository academicRepository;

  TeacherAssignmentsNotifier({required this.academicRepository})
    : super(TeacherAssignmentsState());

  Future<void> loadTeacherAssignmentGroups(String schoolId) async {
    if (state.isLoading) return;
    if (state.hasLoaded && state.schoolId == schoolId) return;

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      errorMessages: const [],
    );

    try {
      final groups = await academicRepository.getTeacherAssignmentGroups(
        schoolId,
      );
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        groups: groups,
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

    return 'No fue posible cargar las asignaciones del docente.';
  }
}

class TeacherAssignmentsState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final List<TeacherAssignmentCourseGroup> groups;
  final List<String> errorMessages;

  TeacherAssignmentsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.groups = const [],
    this.errorMessages = const [],
  });

  TeacherAssignmentsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    List<TeacherAssignmentCourseGroup>? groups,
    List<String>? errorMessages,
  }) => TeacherAssignmentsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    groups: groups ?? this.groups,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
