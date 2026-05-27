import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/communications/data/repositories/repositories.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/communication_repository_provider.dart';

final teacherCommunicationStudentsProvider =
    StateNotifierProvider<TeacherCommunicationStudentsNotifier, TeacherCommunicationStudentsState>((ref) {
      final repository = ref.watch(communicationRepositoryProvider);
      return TeacherCommunicationStudentsNotifier(repository: repository);
    });

class TeacherCommunicationStudentsNotifier extends StateNotifier<TeacherCommunicationStudentsState> {
  final CommunicationRepository repository;

  TeacherCommunicationStudentsNotifier({required this.repository})
    : super(TeacherCommunicationStudentsState());

  Future<void> load(String schoolId, String courseId, {bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.hasLoaded && state.schoolId == schoolId && state.courseId == courseId) return;

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      courseId: courseId,
      errorMessages: const [],
    );

    try {
      final students = await repository.getTeacherCommunicationStudentsByCourse(schoolId, courseId);
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        students: students,
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
    return 'No fue posible cargar los estudiantes del curso.';
  }
}

class TeacherCommunicationStudentsState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String courseId;
  final List<TeacherCommunicationStudent> students;
  final List<String> errorMessages;

  TeacherCommunicationStudentsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.courseId = '',
    this.students = const [],
    this.errorMessages = const [],
  });

  TeacherCommunicationStudentsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? courseId,
    List<TeacherCommunicationStudent>? students,
    List<String>? errorMessages,
  }) => TeacherCommunicationStudentsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    courseId: courseId ?? this.courseId,
    students: students ?? this.students,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
