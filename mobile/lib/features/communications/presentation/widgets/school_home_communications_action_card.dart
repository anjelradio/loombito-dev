import 'package:flutter/material.dart';
import 'package:mobile/features/communications/presentation/widgets/communication_mode_sheet.dart';
import 'package:mobile/features/schools/presentation/widgets/school_home/school_home.dart';

class SchoolHomeCommunicationsActionCard extends StatelessWidget {
  final String schoolId;
  final double height;

  const SchoolHomeCommunicationsActionCard({
    super.key,
    required this.schoolId,
    this.height = 178,
  });

  Future<void> _openSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommunicationModeSheet(schoolId: schoolId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SchoolHomeActionCard(
        title: 'Comunicados',
        description: 'Explora cursos, estudiantes y comunicados publicados.',
        icon: Icons.campaign_outlined,
        startColor: const Color(0xFF1A4E63),
        endColor: const Color(0xFF2B6F8B),
        onTap: () => _openSheet(context),
      ),
    );
  }
}
