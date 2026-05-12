import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/presentation/providers/account/personal_info_form_provider.dart';
import 'package:mobile/features/shared/shared.dart';

class PersonalInfoFormCard extends ConsumerWidget {
  const PersonalInfoFormCard({super.key});

  void showSnackbar(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final formState = ref.watch(personalInfoFormProvider);

    ref.listen(personalInfoFormProvider, (previous, next) {
      final hasFinishedPosting = previous?.isPosting == true && !next.isPosting;
      final wasSubmitAttempt = previous?.hasChanges == true;
      final wasSuccessfulSubmit =
          hasFinishedPosting && wasSubmitAttempt && !next.hasChanges;

      if (!wasSuccessfulSubmit) return;

      showSnackbar(
        context,
        'Información actualizada correctamente',
        isError: false,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informacion personal',
          style: textTheme.titleSmall?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        AppFormLayout(
          fields: [
            CustomTextFormField(
              label: 'Nombre',
              initialValue: formState.firstName.value,
              hint: 'Ingresa tu nombre',
              onChanged: ref
                  .read(personalInfoFormProvider.notifier)
                  .onFirstNameChange,
              errorMessage: formState.isFormPosted
                  ? formState.firstName.errorMessage
                  : null,
            ),
            CustomTextFormField(
              label: 'Apellido',
              initialValue: formState.lastName.value,
              hint: 'Ingresa tu apellido',
              onChanged: ref
                  .read(personalInfoFormProvider.notifier)
                  .onLastNameChange,
              errorMessage: formState.isFormPosted
                  ? formState.lastName.errorMessage
                  : null,
            ),
          ],
          submitText: 'Guardar cambios',
          onSubmit: formState.canSubmit
              ? ref.read(personalInfoFormProvider.notifier).onFormSubmit
              : null,
          fieldSpacing: 14,
          submitButtonHeight: 46,
        ),
      ],
    );
  }
}
