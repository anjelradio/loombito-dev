import 'package:formz/formz.dart';

enum EvaluationDescriptionError { length }

class EvaluationDescription
    extends FormzInput<String, EvaluationDescriptionError> {
  const EvaluationDescription.pure() : super.pure('');

  const EvaluationDescription.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == EvaluationDescriptionError.length) {
      return 'La descripcion no puede exceder 500 caracteres';
    }
    return null;
  }

  @override
  EvaluationDescriptionError? validator(String value) {
    if (value.trim().length > 500) return EvaluationDescriptionError.length;
    return null;
  }
}
