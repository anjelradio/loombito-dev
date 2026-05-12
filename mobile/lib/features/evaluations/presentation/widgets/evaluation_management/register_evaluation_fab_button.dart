import 'package:flutter/material.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

import 'create_evaluation_form.dart';

class RegisterEvaluationFabButton extends StatelessWidget {
  final String schoolId;
  final String assignmentId;
  final List<EvaluationTypeOption> typeOptions;
  final List<EvaluationTermOption> termOptions;
  final VoidCallback onCreated;

  const RegisterEvaluationFabButton({
    super.key,
    required this.schoolId,
    required this.assignmentId,
    required this.typeOptions,
    required this.termOptions,
    required this.onCreated,
  });

  Future<void> _openRegisterEvaluationSheet(BuildContext context) async {
    final config = EvaluationFormConfig(
      schoolId: schoolId,
      assignmentId: assignmentId,
      typeOptions: typeOptions,
      termOptions: termOptions,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.79,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar evaluacion',
                      style: Theme.of(sheetContext).textTheme.titleMedium
                          ?.copyWith(
                            color: const Color(0xFF0F2C4F),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completa los datos para crear una nueva evaluacion en esta materia.',
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 14),
                    CreateEvaluationForm(
                      config: config,
                      onClose: () => Navigator.of(sheetContext).pop(),
                      onSubmitted: (result) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: result.success
                                ? const Color.fromARGB(255, 31, 110, 69)
                                : Colors.red.shade800,
                          ),
                        );
                        if (result.success) onCreated();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalPageFabButton(
      onTap: () => _openRegisterEvaluationSheet(context),
      text: 'Registrar evaluacion',
      icon: Icons.add,
    );
  }
}
