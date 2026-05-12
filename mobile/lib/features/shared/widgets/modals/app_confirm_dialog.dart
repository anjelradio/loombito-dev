import 'package:flutter/material.dart';
import 'package:mobile/features/shared/widgets/modals/app_dialog_shell.dart';
import 'package:mobile/features/shared/widgets/ui/custom_filled_button.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    this.cancelText = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      title: title,
      description: description,
      child: Row(
        children: [
          Expanded(
            child: CustomFilledButton(
              buttonColor: const Color(0xFFFDECEC),
              textColor: const Color(0xFF9F2F2F),
              onPressed: () => Navigator.of(context).pop(false),
              text: cancelText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomFilledButton(
              text: confirmText,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }
}
