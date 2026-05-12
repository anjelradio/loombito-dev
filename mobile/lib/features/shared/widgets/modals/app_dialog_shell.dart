import 'package:flutter/material.dart';
import 'package:mobile/features/shared/widgets/ui/custom_filled_button.dart';

class AppDialogShell extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onCancel;
  final String cancelText;

  const AppDialogShell({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onCancel,
    this.cancelText = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: const Color(0xFF1F476E),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4B5563),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            child,
            if (onCancel != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CustomFilledButton(
                  text: cancelText,
                  buttonColor: const Color(0xFFFDECEC),
                  textColor: const Color(0xFF9F2F2F),
                  onPressed: onCancel,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
