import 'package:formz/formz.dart';

enum EvaluationDateError { empty, format }

class EvaluationDate extends FormzInput<String, EvaluationDateError> {
  const EvaluationDate.pure() : super.pure('');

  const EvaluationDate.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == EvaluationDateError.empty) {
      return 'La fecha de presentacion es requerida';
    }
    if (displayError == EvaluationDateError.format) {
      return 'La fecha debe tener formato YYYY-MM-DD';
    }
    return null;
  }

  @override
  EvaluationDateError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return EvaluationDateError.empty;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return EvaluationDateError.format;
    }
    return null;
  }
}
