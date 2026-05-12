import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/evaluations/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

import 'evaluation_form_fields.dart';

class CreateEvaluationForm extends ConsumerWidget {
  final EvaluationFormConfig config;
  final VoidCallback onClose;
  final void Function(EvaluationSubmitResult result) onSubmitted;

  const CreateEvaluationForm({
    super.key,
    required this.config,
    required this.onClose,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(evaluationFormProvider(config));
    final formNotifier = ref.read(evaluationFormProvider(config).notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EvaluationFormFields(config: config),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomFilledButton(
                text: 'Cancelar',
                buttonColor: const Color(0xFFE4EBF4),
                textColor: const Color(0xFF1F476E),
                onPressed: onClose,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomFilledButton(
                text: formState.isPosting
                    ? 'Registrando...'
                    : 'Registrar evaluacion',
                onPressed: formState.isPosting
                    ? null
                    : () async {
                        final result = await formNotifier.onSubmit();
                        if (result.closeModal) onClose();
                        onSubmitted(result);
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
