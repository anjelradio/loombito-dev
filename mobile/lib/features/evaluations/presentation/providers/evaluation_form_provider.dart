import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:mobile/features/evaluations/data/repositories/repositories.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/evaluation_repository_provider.dart';
import 'package:mobile/features/shared/shared.dart';

class EvaluationFormConfig {
  final String schoolId;
  final String assignmentId;
  final String? evaluationId;
  final Evaluation? initialEvaluation;
  final List<EvaluationTypeOption> typeOptions;
  final List<EvaluationTermOption> termOptions;

  const EvaluationFormConfig({
    required this.schoolId,
    required this.assignmentId,
    this.evaluationId,
    this.initialEvaluation,
    required this.typeOptions,
    required this.termOptions,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationFormConfig &&
        other.schoolId == schoolId &&
        other.assignmentId == assignmentId &&
        other.evaluationId == evaluationId;
  }

  @override
  int get hashCode => Object.hash(schoolId, assignmentId, evaluationId);
}

class EvaluationSubmitResult {
  final bool success;
  final String message;
  final bool closeModal;

  const EvaluationSubmitResult({
    required this.success,
    required this.message,
    required this.closeModal,
  });
}

final evaluationFormProvider = StateNotifierProvider.autoDispose
    .family<EvaluationFormNotifier, EvaluationFormState, EvaluationFormConfig>((
      ref,
      config,
    ) {
      final repository = ref.watch(evaluationRepositoryProvider);
      return EvaluationFormNotifier(repository: repository, config: config);
    });

class EvaluationFormNotifier extends StateNotifier<EvaluationFormState> {
  final EvaluationRepository repository;
  final EvaluationFormConfig config;

  EvaluationFormNotifier({required this.repository, required this.config})
    : super(_buildInitialState(config));

  static EvaluationFormState _buildInitialState(EvaluationFormConfig config) {
    String? defaultTermId;
    for (final term in config.termOptions) {
      if (term.isActive) {
        defaultTermId = term.id;
        break;
      }
    }

    final defaultTypeId = config.typeOptions.isNotEmpty
        ? config.typeOptions.first.id
        : '';

    final initialTypeId =
        config.initialEvaluation?.evaluationTypeId ?? defaultTypeId;
    final initialTermId =
        config.initialEvaluation?.termId ?? (defaultTermId ?? '');
    final initialDate = config.initialEvaluation?.presentationDate ?? '';
    final initialName = config.initialEvaluation?.name ?? '';
    final initialDescription = config.initialEvaluation?.description ?? '';

    final termInput = EvaluationOptionId.dirty(initialTermId);
    final typeInput = EvaluationOptionId.dirty(initialTypeId);
    final nameInput = EvaluationName.dirty(initialName);
    final descriptionInput = EvaluationDescription.dirty(initialDescription);
    final dateInput = EvaluationDate.dirty(initialDate);

    return EvaluationFormState(
      name: nameInput,
      description: descriptionInput,
      presentationDate: dateInput,
      termId: termInput,
      evaluationTypeId: typeInput,
      isValid: Formz.validate([
        nameInput,
        descriptionInput,
        dateInput,
        termInput,
        typeInput,
      ]),
    );
  }

  void onNameChanged(String value) {
    final name = EvaluationName.dirty(value);
    state = state.copyWith(
      name: name,
      isValid: _validate(name: name),
    );
  }

  void onDescriptionChanged(String value) {
    final description = EvaluationDescription.dirty(value);
    state = state.copyWith(
      description: description,
      isValid: _validate(description: description),
    );
  }

  void onPresentationDateChanged(String value) {
    final date = EvaluationDate.dirty(value);
    state = state.copyWith(
      presentationDate: date,
      isValid: _validate(presentationDate: date),
    );
  }

  void onTypeChanged(String value) {
    final type = EvaluationOptionId.dirty(value);
    state = state.copyWith(
      evaluationTypeId: type,
      isValid: _validate(evaluationTypeId: type),
    );
  }

  void onTermChanged(String value) {
    final term = EvaluationOptionId.dirty(value);
    state = state.copyWith(
      termId: term,
      isValid: _validate(termId: term),
    );
  }

  Future<EvaluationSubmitResult> onSubmit() async {
    _touchAll();
    if (!state.isValid) {
      return const EvaluationSubmitResult(
        success: false,
        message: 'Revisa los campos del formulario.',
        closeModal: false,
      );
    }

    state = state.copyWith(isPosting: true, errorMessages: const []);

    try {
      if (config.evaluationId == null) {
        await repository.createEvaluation(
          config.schoolId,
          config.assignmentId,
          state.name.value.trim(),
          state.description.value.trim(),
          state.presentationDate.value.trim(),
          state.termId.value,
          state.evaluationTypeId.value,
        );
      } else {
        await repository.updateEvaluation(
          config.schoolId,
          config.evaluationId!,
          state.name.value.trim(),
          state.description.value.trim(),
          state.presentationDate.value.trim(),
          state.termId.value,
          state.evaluationTypeId.value,
        );
      }

      state = state.copyWith(isPosting: false, errorMessages: const []);
      return EvaluationSubmitResult(
        success: true,
        message: config.evaluationId == null
            ? 'Evaluacion registrada correctamente'
            : 'Evaluacion actualizada correctamente',
        closeModal: true,
      );
    } on DioException catch (error) {
      final parsed = parseApiErrors(error.response?.data);
      final message = parsed.isNotEmpty
          ? parsed.first
          : config.evaluationId == null
          ? 'No fue posible registrar la evaluacion.'
          : 'No fue posible actualizar la evaluacion.';
      state = state.copyWith(
        isPosting: false,
        errorMessages: parsed.isNotEmpty ? parsed : [message],
      );
      return EvaluationSubmitResult(
        success: false,
        message: message,
        closeModal: true,
      );
    } catch (_) {
      final message = config.evaluationId == null
          ? 'No fue posible registrar la evaluacion.'
          : 'No fue posible actualizar la evaluacion.';
      state = state.copyWith(isPosting: false, errorMessages: [message]);
      return EvaluationSubmitResult(
        success: false,
        message: message,
        closeModal: true,
      );
    }
  }

  bool _validate({
    EvaluationName? name,
    EvaluationDescription? description,
    EvaluationDate? presentationDate,
    EvaluationOptionId? termId,
    EvaluationOptionId? evaluationTypeId,
  }) {
    return Formz.validate([
      name ?? state.name,
      description ?? state.description,
      presentationDate ?? state.presentationDate,
      termId ?? state.termId,
      evaluationTypeId ?? state.evaluationTypeId,
    ]);
  }

  void _touchAll() {
    final name = EvaluationName.dirty(state.name.value);
    final description = EvaluationDescription.dirty(state.description.value);
    final date = EvaluationDate.dirty(state.presentationDate.value);
    final termId = EvaluationOptionId.dirty(state.termId.value);
    final evaluationTypeId = EvaluationOptionId.dirty(
      state.evaluationTypeId.value,
    );

    state = state.copyWith(
      isFormPosted: true,
      name: name,
      description: description,
      presentationDate: date,
      termId: termId,
      evaluationTypeId: evaluationTypeId,
      isValid: Formz.validate([
        name,
        description,
        date,
        termId,
        evaluationTypeId,
      ]),
    );
  }
}

class EvaluationFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final EvaluationName name;
  final EvaluationDescription description;
  final EvaluationDate presentationDate;
  final EvaluationOptionId termId;
  final EvaluationOptionId evaluationTypeId;
  final List<String> errorMessages;

  const EvaluationFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.name = const EvaluationName.pure(),
    this.description = const EvaluationDescription.pure(),
    this.presentationDate = const EvaluationDate.pure(),
    this.termId = const EvaluationOptionId.pure(),
    this.evaluationTypeId = const EvaluationOptionId.pure(),
    this.errorMessages = const [],
  });

  EvaluationFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    EvaluationName? name,
    EvaluationDescription? description,
    EvaluationDate? presentationDate,
    EvaluationOptionId? termId,
    EvaluationOptionId? evaluationTypeId,
    List<String>? errorMessages,
  }) => EvaluationFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    description: description ?? this.description,
    presentationDate: presentationDate ?? this.presentationDate,
    termId: termId ?? this.termId,
    evaluationTypeId: evaluationTypeId ?? this.evaluationTypeId,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}
