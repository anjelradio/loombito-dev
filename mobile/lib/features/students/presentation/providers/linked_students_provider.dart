import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/students/data/repositories/repositories.dart';
import 'package:mobile/features/students/domain/domain.dart';
import 'package:mobile/features/students/presentation/providers/student_repository_provider.dart';

final linkedStudentsProvider =
    StateNotifierProvider<LinkedStudentsNotifier, LinkedStudentsState>((ref) {
      final studentRepository = ref.watch(studentRepositoryProvider);
      return LinkedStudentsNotifier(studentRepository: studentRepository);
    });

class LinkedStudentsNotifier extends StateNotifier<LinkedStudentsState> {
  final StudentRepository studentRepository;

  LinkedStudentsNotifier({required this.studentRepository})
      : super(LinkedStudentsState());

  Future<void> loadLinkedStudents() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessages: const []);

    try {
      final students = await studentRepository.getStudentsByUser();
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        students: students,
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
        errorMessages: const ['Error de conexion. Intentalo nuevamente.'],
      );
    }
  }

  String _resolveDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Error de conexion. Intentalo nuevamente.';
    }

    return 'No fue posible cargar tus estudiantes vinculados.';
  }

  void addOrUpdateLinkedStudent(LinkedStudent student) {
    final currentStudents = [...state.students];
    final index = currentStudents.indexWhere((item) => item.id == student.id);

    if (index >= 0) {
      currentStudents[index] = student;
    } else {
      currentStudents.insert(0, student);
    }

    state = state.copyWith(
      students: currentStudents,
      hasLoaded: true,
      errorMessages: const [],
    );
  }
}

class LinkedStudentsState {
  final bool isLoading;
  final bool hasLoaded;
  final List<LinkedStudent> students;
  final List<String> errorMessages;

  LinkedStudentsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.students = const [],
    this.errorMessages = const [],
  });

  LinkedStudentsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<LinkedStudent>? students,
    List<String>? errorMessages,
  }) => LinkedStudentsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    students: students ?? this.students,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
