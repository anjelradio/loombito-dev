import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

class EmailChangeCard extends ConsumerWidget {
  const EmailChangeCard({super.key});

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

  Future<void> _onChangeEmailPressed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Cambiar correo electronico',
        description:
            '¿Quieres cambiar tu correo electronico? Te enviaremos un codigo OTP a tu correo actual.',
        confirmText: 'Si',
        cancelText: 'No',
      ),
    );

    if (shouldContinue != true || !context.mounted) return;

    final wasSent = await ref
        .read(emailChangeFormProvider.notifier)
        .requestOtp();
    if (!wasSent || !context.mounted) return;

    _showSnackbar(
      context,
      'Codigo OTP enviado a tu correo actual',
      isError: false,
    );
    await _openOtpDialog(context, ref);
  }

  Future<void> _openOtpDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final formState = ref.watch(emailChangeFormProvider);
            final notifier = ref.read(emailChangeFormProvider.notifier);

            return AppDialogShell(
              title: 'Verificar codigo OTP',
              description:
                  'Hemos enviado un codigo OTP a tu correo actual. Ingresalo para continuar.',
              child: AppFormLayout(
                fields: [
                  CustomTextFormField(
                    label: 'Codigo OTP',
                    keyboardType: TextInputType.number,
                    hint: 'Ingresa el codigo de 6 digitos',
                    initialValue: formState.otp.value,
                    onChanged: notifier.onOtpChange,
                    errorMessage: formState.isOtpFormPosted
                        ? formState.otp.errorMessage
                        : null,
                  ),
                ],
                submitText: 'Verificar codigo',
                onSubmit: formState.canVerifyOtp
                    ? () async {
                        final isValidOtp = await notifier.verifyOtp();
                        if (!context.mounted || !isValidOtp) return;

                        Navigator.of(dialogContext).pop();
                        _showSnackbar(
                          context,
                          'Codigo OTP verificado correctamente',
                          isError: false,
                        );
                        await _openNewEmailDialog(context, ref);
                      }
                    : null,
                fieldSpacing: 14,
                submitButtonHeight: 46,
              ),
              onCancel: () {
                ref.read(emailChangeFormProvider.notifier).reset();
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openNewEmailDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final formState = ref.watch(emailChangeFormProvider);
            final notifier = ref.read(emailChangeFormProvider.notifier);

            return AppDialogShell(
              title: 'Nuevo correo electronico',
              description:
                  'Ingresa tu nuevo correo para actualizar la informacion de tu cuenta.',
              child: AppFormLayout(
                fields: [
                  CustomTextFormField(
                    label: 'Nuevo correo',
                    keyboardType: TextInputType.emailAddress,
                    hint: 'nuevo-correo@ejemplo.com',
                    initialValue: formState.newEmail.value,
                    onChanged: notifier.onNewEmailChange,
                    errorMessage: formState.isNewEmailFormPosted
                        ? formState.newEmail.errorMessage
                        : null,
                  ),
                ],
                submitText: 'Actualizar correo',
                onSubmit: formState.canSubmitNewEmail
                    ? () async {
                        final wasUpdated = await notifier.submitNewEmail();
                        if (!context.mounted || !wasUpdated) return;

                        Navigator.of(dialogContext).pop();
                        _showSnackbar(
                          context,
                          'Correo electronico actualizado correctamente',
                          isError: false,
                        );
                      }
                    : null,
                fieldSpacing: 14,
                submitButtonHeight: 46,
              ),
              onCancel: () {
                ref.read(emailChangeFormProvider.notifier).reset();
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
    final userEmail = ref.watch(authProvider).user?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electronico',
          style: textTheme.titleSmall?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Este correo esta vinculado a tu cuenta actual y puedes actualizarlo cuando quieras.',
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF4B5563),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        CustomTextFormField(
          key: ValueKey(userEmail),
          label: 'Correo actual',
          initialValue: userEmail,
          readOnly: true,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: CustomFilledButton(
            text: 'Cambiar correo electronico',
            onPressed: () => _onChangeEmailPressed(context, ref),
          ),
        ),
      ],
    );
  }
}
