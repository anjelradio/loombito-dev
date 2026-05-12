import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/presentation/providers/account/password_change_form_provider.dart';
import 'package:mobile/features/shared/shared.dart';

class PasswordChangeCard extends ConsumerWidget {
  const PasswordChangeCard({super.key});

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade800
            : const Color.fromARGB(255, 31, 110, 69),
      ),
    );
  }

  Future<void> _openPasswordDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final formState = ref.watch(passwordChangeFormProvider);
            final notifier = ref.read(passwordChangeFormProvider.notifier);

            return AppDialogShell(
              title: 'Cambiar contraseña',
              description:
                  'Ingresa tu contraseña actual y define una nueva contraseña para tu cuenta.',
              child: AppFormLayout(
                fields: [
                  CustomTextFormField(
                    label: 'Contraseña actual',
                    obscureText: true,
                    onChanged: notifier.onCurrentPasswordChange,
                    errorMessage: formState.currentPasswordError,
                  ),
                  CustomTextFormField(
                    label: 'Nueva contraseña',
                    obscureText: true,
                    onChanged: notifier.onNewPasswordChange,
                    errorMessage: formState.newPasswordError,
                  ),
                  CustomTextFormField(
                    label: 'Confirmar nueva contraseña',
                    obscureText: true,
                    onChanged: notifier.onConfirmNewPasswordChange,
                    errorMessage: formState.confirmNewPasswordError,
                  ),
                ],
                submitText: 'Actualizar contraseña',
                onSubmit: formState.canSubmit
                    ? () async {
                        final wasUpdated = await notifier.onFormSubmit();
                        if (!context.mounted || !wasUpdated) return;

                        Navigator.of(dialogContext).pop();
                        _showSnackbar(
                          context,
                          'Contraseña actualizada correctamente',
                          isError: false,
                        );
                      }
                    : null,
                fieldSpacing: 14,
                submitButtonHeight: 46,
              ),
              onCancel: () {
                notifier.reset();
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: textTheme.titleSmall?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Por seguridad puedes cambiar tu contraseña y mantener protegida tu cuenta.',
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF4B5563),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: CustomFilledButton(
            text: 'Cambiar contraseña',
            onPressed: () => _openPasswordDialog(context, ref),
          ),
        ),
      ],
    );
  }
}
