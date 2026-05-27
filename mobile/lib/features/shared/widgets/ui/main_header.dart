import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/shared/widgets/ui/custom_filled_button.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Image.asset('assets/images/logo/loombo-blue.png', height: 38),
        const SizedBox(width: 8),
        Text(
          'LoomBo',
          style: textTheme.titleMedium?.copyWith(
            color: CustomFilledButton.defaultButtonColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _CircleIconButton(
          icon: Icons.notifications,
          onPressed: () => context.push('/communications/notifications'),
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.person,
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
