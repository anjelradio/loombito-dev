import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/providers/providers.dart';
import 'package:mobile/features/auth/presentation/widgets/account/email_change_card.dart';
import 'package:mobile/features/auth/presentation/widgets/account/personal_info_form_card.dart';
import 'package:mobile/features/auth/presentation/widgets/account/password_change_card.dart';
import 'package:mobile/features/shared/shared.dart';

class PersonalDataScreen extends ConsumerWidget {
  const PersonalDataScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      final hasError = next.errorMessages.isNotEmpty;
      final previousError =
          previous != null && previous.errorMessages.isNotEmpty
          ? previous.errorMessages.first
          : null;
      final currentError = hasError ? next.errorMessages.first : null;

      if (!hasError || previousError == currentError) return;
      _showSnackbar(context, currentError!);
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg/bg-profile.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.black12),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xAA0E3256),
                      Color(0xCC0C2947),
                      Color(0xE60A2038),
                    ],
                    stops: [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    children: const [
                      _ProfileHeader(),
                      SizedBox(height: 24),
                      _CardsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _IconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: context.pop,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Mis datos personales',
              style: textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _BaseCard(child: PersonalInfoFormCard()),
        SizedBox(height: 16),
        _BaseCard(child: EmailChangeCard()),
        SizedBox(height: 16),
        _BaseCard(child: PasswordChangeCard()),
        SizedBox(height: 22),
        _LogoutButton(),
      ],
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  Future<void> _onLogoutPressed(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Cerrar sesión',
        description: '¿Seguro que quieres cerrar sesión?',
        confirmText: 'Cerrar sesión',
      ),
    );

    if (shouldLogout == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: CustomFilledButton(
        text: 'Cerrar sesión',
        buttonColor: Colors.white,
        textColor: const Color(0xFF1F476E),
        onPressed: () => _onLogoutPressed(context, ref),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;

  const _BaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: child,
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
