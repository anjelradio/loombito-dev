import 'package:formz/formz.dart';

enum EvaluationOptionIdError { empty }

class EvaluationOptionId extends FormzInput<String, EvaluationOptionIdError> {
  const EvaluationOptionId.pure() : super.pure('');

  const EvaluationOptionId.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == EvaluationOptionIdError.empty) {
      return 'Selecciona una opcion';
    }
    return null;
  }

  @override
  EvaluationOptionIdError? validator(String value) {
    if (value.trim().isEmpty) return EvaluationOptionIdError.empty;
    return null;
  }
}
