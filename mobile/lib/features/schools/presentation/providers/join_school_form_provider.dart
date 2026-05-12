import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:mobile/features/schools/domain/domain.dart';
import 'package:mobile/features/schools/presentation/providers/school_repository_provider.dart';
import 'package:mobile/features/schools/presentation/providers/schools_provider.dart';
import 'package:mobile/features/shared/shared.dart';

final joinSchoolFormProvider =
    StateNotifierProvider.autoDispose<
      JoinSchoolFormNotifier,
      JoinSchoolFormState
    >((ref) {
      final schoolRepository = ref.watch(schoolRepositoryProvider);
      final schoolsNotifier = ref.read(schoolsProvider.notifier);

      return JoinSchoolFormNotifier(
        joinSchoolByCodeCallback: schoolRepository.joinSchoolByCode,
        onSchoolJoined: schoolsNotifier.addOrUpdateSchool,
      );
    });

class JoinSchoolFormNotifier extends StateNotifier<JoinSchoolFormState> {
  final Future<School> Function(String code) joinSchoolByCodeCallback;
  final void Function(School school) onSchoolJoined;

  JoinSchoolFormNotifier({
    required this.joinSchoolByCodeCallback,
    required this.onSchoolJoined,
  }) : super(JoinSchoolFormState());

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
      final school = await joinSchoolByCodeCallback(
        state.code.value.trim().toUpperCase(),
      );
      if (!mounted) return false;

      onSchoolJoined(school);
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
        errorMessages: const ['Error de conexión. Inténtalo nuevamente.'],
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

class JoinSchoolFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final JoinCode code;
  final List<String> errorMessages;

  bool get canSubmit => isValid && !isPosting;

  JoinSchoolFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.code = const JoinCode.pure(),
    this.errorMessages = const [],
  });

  JoinSchoolFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    JoinCode? code,
    List<String>? errorMessages,
  }) => JoinSchoolFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    code: code ?? this.code,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
