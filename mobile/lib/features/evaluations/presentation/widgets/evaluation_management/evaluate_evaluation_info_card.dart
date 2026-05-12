import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:mobile/features/students/students.dart';

class EvaluateEvaluationInfoCard extends StatelessWidget {
  final String schoolId;
  final Evaluation evaluation;
  final VoidCallback onFinalized;
  final void Function(String message) onError;

  const EvaluateEvaluationInfoCard({
    super.key,
    required this.schoolId,
    required this.evaluation,
    required this.onFinalized,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            evaluation.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F2C4F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Descripcion', value: evaluation.description ?? '-'),
          _InfoRow(label: 'Tipo', value: evaluation.evaluationTypeName),
          _InfoRow(label: 'Presentacion', value: evaluation.presentationDate),
          _InfoRow(label: 'Trimestre', value: evaluation.termName),
          _InfoRow(
            label: 'Estado',
            value: evaluation.isClosed ? 'Finalizada' : 'Activa',
          ),
          const SizedBox(height: 10),
          FinalizeEvaluationButton(
            schoolId: schoolId,
            evaluationId: evaluation.id,
            disabled: evaluation.isClosed,
            onFinalized: onFinalized,
            onError: onError,
          ),
        ],
      ),
    );
  }
}

class FinalizeEvaluationButton extends ConsumerStatefulWidget {
  final String schoolId;
  final String evaluationId;
  final bool disabled;
  final VoidCallback onFinalized;
  final void Function(String message) onError;

  const FinalizeEvaluationButton({
    super.key,
    required this.schoolId,
    required this.evaluationId,
    required this.disabled,
    required this.onFinalized,
    required this.onError,
  });

  @override
  ConsumerState<FinalizeEvaluationButton> createState() =>
      _FinalizeEvaluationButtonState();
}

class _FinalizeEvaluationButtonState
    extends ConsumerState<FinalizeEvaluationButton> {
  bool _isSubmitting = false;

  Future<void> _onTap() async {
    if (widget.disabled || _isSubmitting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Finalizar evaluacion',
        description:
            'Se completaran con cero los estudiantes sin calificar. Esta accion no se puede deshacer.',
        confirmText: 'Finalizar',
        cancelText: 'Cancelar',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final summary = await ref
          .read(studentRepositoryProvider)
          .finalizeEvaluation(widget.schoolId, widget.evaluationId);
      if (!mounted) return;
      widget.onFinalized();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Evaluacion finalizada. Faltantes creados en cero: ${summary.createdMissing}',
          ),
          backgroundColor: const Color.fromARGB(255, 31, 110, 69),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      widget.onError('No se pudo finalizar la evaluacion.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || _isSubmitting;

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: widget.disabled
            ? 'Evaluacion finalizada'
            : _isSubmitting
            ? 'Finalizando...'
            : 'Finalizar evaluacion',
        onPressed: isDisabled ? null : _onTap,
        buttonColor: widget.disabled ? const Color(0xFFDCE8F5) : null,
        textColor: widget.disabled ? const Color(0xFF345B86) : null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF1F476E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
