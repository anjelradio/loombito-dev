import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/communications/data/repositories/repositories.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/communication_repository_provider.dart';

final teacherCommunicationCoursesProvider =
    StateNotifierProvider<TeacherCommunicationCoursesNotifier, TeacherCommunicationCoursesState>((ref) {
      final repository = ref.watch(communicationRepositoryProvider);
      return TeacherCommunicationCoursesNotifier(repository: repository);
    });

class TeacherCommunicationCoursesNotifier extends StateNotifier<TeacherCommunicationCoursesState> {
  final CommunicationRepository repository;

  TeacherCommunicationCoursesNotifier({required this.repository}) : super(TeacherCommunicationCoursesState());

  Future<void> load(String schoolId, {bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.hasLoaded && state.schoolId == schoolId) return;

    state = state.copyWith(isLoading: true, schoolId: schoolId, errorMessages: const []);

    try {
      final courses = await repository.getTeacherCommunicationCourses(schoolId);
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        courses: courses,
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
    return 'No fue posible cargar los cursos para comunicados.';
  }
}

class TeacherCommunicationCoursesState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final List<TeacherCommunicationCourse> courses;
  final List<String> errorMessages;

  TeacherCommunicationCoursesState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.courses = const [],
    this.errorMessages = const [],
  });

  TeacherCommunicationCoursesState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    List<TeacherCommunicationCourse>? courses,
    List<String>? errorMessages,
  }) => TeacherCommunicationCoursesState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    courses: courses ?? this.courses,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
