import 'package:flutter/material.dart';
import 'package:mobile/features/shared/widgets/ui/custom_filled_button.dart';

class AppCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

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
