import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:mobile/features/students/students.dart';

class JoinStudentCodeScreen extends ConsumerWidget {
  const JoinStudentCodeScreen({super.key});

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade800 : const Color.fromARGB(255, 31, 110, 69),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final joinFormState = ref.watch(joinStudentFormProvider);
    final joinFormNotifier = ref.read(joinStudentFormProvider.notifier);

    ref.listen(joinStudentFormProvider, (previous, next) {
      final hasError = next.errorMessages.isNotEmpty;
      final previousError =
          previous != null && previous.errorMessages.isNotEmpty ? previous.errorMessages.first : null;
      final currentError = hasError ? next.errorMessages.first : null;

      if (!hasError || previousError == currentError) return;
      _showSnackbar(context, currentError!);
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(onBack: context.pop),
                const SizedBox(height: 20),
                Text(
                  'ACCEDISTE COMO',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                _UserIdentityCard(
                  fullName: fullName.isEmpty ? 'Usuario' : fullName,
                  email: user?.email ?? '',
                ),
                const SizedBox(height: 18),
                _InfoCard(),
                const SizedBox(height: 18),
                AppFormLayout(
                  fields: [
                    CustomTextFormField(
                      label: 'Codigo de vinculacion',
                      hint: 'Codigo de vinculacion',
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: joinFormNotifier.onCodeChange,
                      errorMessage: joinFormState.isFormPosted ? joinFormState.code.errorMessage : null,
                    ),
                    Text(
                      'Pidele al administrador de la escuela el codigo de vinculacion del estudiante.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.35,
                          ),
                    ),
                  ],
                  submitText: 'Vincularse',
                  onSubmit: joinFormState.canSubmit
                      ? () async {
                          final wasLinked = await joinFormNotifier.onFormSubmit();
                          if (!context.mounted || !wasLinked) return;

                          _showSnackbar(
                            context,
                            'Te vinculaste al estudiante correctamente',
                            isError: false,
                          );
                          context.pop();
                        }
                      : null,
                  submitButtonHeight: 48,
                  fieldSpacing: 14,
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ScreenHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        const SizedBox(width: 6),
        Text(
          'Vincularse a un estudiante',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0F2C4F),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _UserIdentityCard extends StatelessWidget {
  final String fullName;
  final String email;

  const _UserIdentityCard({required this.fullName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF1F476E).withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 28,
              color: Color(0xFF1F476E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Pidele al administrador de la escuela el codigo del estudiante y luego ingresalo aqui.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF374151),
              height: 1.4,
            ),
      ),
    );
  }
}
