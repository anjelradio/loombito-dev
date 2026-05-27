import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/shared/widgets/ui/custom_filled_button.dart';

class SchoolHomeHeader extends StatelessWidget {
  const SchoolHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: context.pop,
        ),
        const Spacer(),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () => context.push('/communications/notifications'),
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.person_outline_rounded,
          onPressed: () => context.push('/profile/personal-data'),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomFilledButton.defaultButtonColor,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
