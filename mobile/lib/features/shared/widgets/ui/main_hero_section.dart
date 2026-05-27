import 'package:flutter/material.dart';
import 'package:mobile/features/shared/widgets/app_section_header.dart';

class MainHeroSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const MainHeroSection({
    super.key,
    this.title = 'Mis colegios',
    this.subtitle = 'Bienvenido. Aqui puedes ver tus instituciones vinculadas.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2C4F), Color(0xFF1E4A75)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2C4F).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -52,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: AppSectionHeader(
              title: title,
              subtitle: subtitle,
              lightOnDark: true,
            ),
          ),
        ],
      ),
    );
  }
}
