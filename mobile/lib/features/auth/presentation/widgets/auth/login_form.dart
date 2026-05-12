import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});
  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseTextStyle = Theme.of(context).textTheme.bodyMedium;
    final loginForm = ref.watch(loginFormProvider);
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      showSnackbar(context, next.errorMessage);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormLayout(
          fields: [
            CustomTextFormField(
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
              errorMessage: loginForm.isFormPosted
                  ? loginForm.email.errorMessage
                  : null,
            ),
            CustomTextFormField(
              label: 'Contraseña',
              obscureText: true,
              onChanged: ref.read(loginFormProvider.notifier).onPasswordChange,
              errorMessage: loginForm.isFormPosted
                  ? loginForm.password.errorMessage
                  : null,
            ),
          ],
          submitText: 'Iniciar Sesión',
          onSubmit: loginForm.isPosting
              ? null
              : ref.read(loginFormProvider.notifier).onFormSubmit,
        ),
        const SizedBox(height: 18),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: baseTextStyle?.copyWith(
                color: const Color(0xFF4B5563),
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            const Divider(height: 32, thickness: 1, color: Color(0xFFE5E7EB)),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '¿No tienes una cuenta?',
                style: baseTextStyle?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.push('/register'),
            child: Text(
              'Crear una Cuenta',
              style: baseTextStyle?.copyWith(
                color: const Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
