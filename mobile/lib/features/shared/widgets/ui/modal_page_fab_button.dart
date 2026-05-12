import 'package:flutter/material.dart';

import 'custom_filled_button.dart';

class ModalPageFabButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const ModalPageFabButton({
    super.key,
    required this.onTap,
    required this.text,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomFilledButton.defaultButtonColor,
      borderRadius: BorderRadius.circular(26),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
