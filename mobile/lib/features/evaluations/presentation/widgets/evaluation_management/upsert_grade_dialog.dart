import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:mobile/features/students/students.dart';

class UpsertGradeDialog extends ConsumerStatefulWidget {
  final String schoolId;
  final String evaluationId;
  final StudentGradebookRow row;
  final VoidCallback onSaved;

  const UpsertGradeDialog({
    super.key,
    required this.schoolId,
    required this.evaluationId,
    required this.row,
    required this.onSaved,
  });

  @override
  ConsumerState<UpsertGradeDialog> createState() => _UpsertGradeDialogState();
}

class _UpsertGradeDialogState extends ConsumerState<UpsertGradeDialog> {
  late String _score;
  late String _observation;
  String? _scoreError;
  String? _observationError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _score = widget.row.score?.toString() ?? '';
    _observation = widget.row.observation ?? '';
  }

  Future<void> _submit() async {
    final parsedScore = double.tryParse(_score.replaceAll(',', '.'));
    final scoreError = _score.trim().isEmpty
        ? 'La nota es obligatoria.'
        : parsedScore == null
        ? 'Ingresa una nota valida.'
        : parsedScore < 0
        ? 'La nota no puede ser negativa.'
        : null;
    final observationError = _observation.length > 300
        ? 'La observacion no puede superar 300 caracteres.'
        : null;

    if (scoreError != null || observationError != null) {
      setState(() {
        _scoreError = scoreError;
        _observationError = observationError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _scoreError = null;
      _observationError = null;
    });

    try {
      await ref
          .read(studentRepositoryProvider)
          .upsertEvaluationGrade(
            widget.schoolId,
            widget.evaluationId,
            widget.row.studentId,
            parsedScore!,
            _observation,
          );
      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      if (!mounted) return;
      final message = parseApiErrors(error.response?.data).first;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo guardar la calificacion.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGraded = widget.row.status == 'calificado';
    final fullName = '${widget.row.lastName} ${widget.row.firstName}';

    return AppDialogShell(
      title: isGraded ? 'Editar calificacion' : 'Calificar estudiante',
      description: fullName,
      child: Column(
        children: [
          CustomTextFormField(
            label: 'Nota',
            hint: 'Ej: 18.50',
            initialValue: _score,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => _score = value,
            errorMessage: _scoreError,
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            label: 'Observacion (opcional)',
            hint: 'Comentario para el estudiante',
            initialValue: _observation,
            onChanged: (value) => _observation = value,
            errorMessage: _observationError,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomFilledButton(
                  text: 'Cancelar',
                  buttonColor: const Color(0xFFFDECEC),
                  textColor: const Color(0xFF9F2F2F),
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomFilledButton(
                  text: _isSaving ? 'Guardando...' : 'Guardar',
                  onPressed: _isSaving ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
