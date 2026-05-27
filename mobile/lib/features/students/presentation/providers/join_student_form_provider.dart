import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:mobile/features/students/domain/domain.dart';
import 'package:mobile/features/students/presentation/providers/linked_students_provider.dart';
import 'package:mobile/features/students/presentation/providers/student_repository_provider.dart';

final joinStudentFormProvider =
    StateNotifierProvider.autoDispose<JoinStudentFormNotifier, JoinStudentFormState>((ref) {
      final studentRepository = ref.watch(studentRepositoryProvider);
      final linkedStudentsNotifier = ref.read(linkedStudentsProvider.notifier);

      return JoinStudentFormNotifier(
        joinStudentByCodeCallback: studentRepository.joinStudentByCode,
        onStudentJoined: linkedStudentsNotifier.addOrUpdateLinkedStudent,
        reloadLinkedStudents: linkedStudentsNotifier.loadLinkedStudents,
      );
    });

class JoinStudentFormNotifier extends StateNotifier<JoinStudentFormState> {
  final Future<LinkedStudent> Function(String code) joinStudentByCodeCallback;
  final void Function(LinkedStudent student) onStudentJoined;
  final Future<void> Function() reloadLinkedStudents;

  JoinStudentFormNotifier({
    required this.joinStudentByCodeCallback,
    required this.onStudentJoined,
    required this.reloadLinkedStudents,
  }) : super(JoinStudentFormState());

  void onCodeChange(String value) {
    final joinCode = JoinCode.dirty(value);
    state = state.copyWith(
      code: joinCode,
      isValid: Formz.validate([joinCode]),
      errorMessages: const [],
    );
  }

  Future<bool> onFormSubmit() async {
    _touchField();
    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true, errorMessages: const []);

    try {
      final student = await joinStudentByCodeCallback(
        state.code.value.trim().toUpperCase(),
      );
      if (!mounted) return false;

      onStudentJoined(student);
      await reloadLinkedStudents();
      state = state.copyWith(
        isPosting: false,
        isFormPosted: false,
        code: const JoinCode.pure(),
        isValid: false,
        errorMessages: const [],
      );
      return true;
    } on DioException catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        isPosting: false,
        errorMessages: parseApiErrors(error.response?.data),
      );
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        isPosting: false,
        errorMessages: const ['Error de conexion. Intentalo nuevamente.'],
      );
      return false;
    }
  }

  void _touchField() {
    final joinCode = JoinCode.dirty(state.code.value);

    state = state.copyWith(
      isFormPosted: true,
      code: joinCode,
      isValid: Formz.validate([joinCode]),
    );
  }
}

class JoinStudentFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final JoinCode code;
  final List<String> errorMessages;

  bool get canSubmit => isValid && !isPosting;

  JoinStudentFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.code = const JoinCode.pure(),
    this.errorMessages = const [],
  });

  JoinStudentFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    JoinCode? code,
    List<String>? errorMessages,
  }) => JoinStudentFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    code: code ?? this.code,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
