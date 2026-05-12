import 'package:formz/formz.dart';

enum EvaluationNameError { empty, length }

class EvaluationName extends FormzInput<String, EvaluationNameError> {
  const EvaluationName.pure() : super.pure('');

  const EvaluationName.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == EvaluationNameError.empty)
      return 'El titulo es requerido';
    if (displayError == EvaluationNameError.length) {
      return 'El titulo debe tener entre 3 y 80 caracteres';
    }
    return null;
  }

  @override
  EvaluationNameError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return EvaluationNameError.empty;
    if (trimmed.length < 3 || trimmed.length > 80) {
      return EvaluationNameError.length;
    }
    return null;
  }
}
