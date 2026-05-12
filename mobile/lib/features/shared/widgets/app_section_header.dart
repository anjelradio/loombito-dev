import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool lightOnDark;

  const AppSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.lightOnDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: lightOnDark ? Colors.white : const Color(0xFF0F2C4F),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: lightOnDark
                ? const Color(0xFFD7E7F9)
                : const Color(0xFF5E6B7D),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
