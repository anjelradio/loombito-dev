import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/academic/academic.dart';
import 'package:mobile/features/schools/presentation/widgets/school_home/school_home.dart';

class SchoolHomeModeActionCard extends ConsumerWidget {
  final String schoolId;
  final TeacherAssignmentMode mode;
  final String title;
  final String description;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final double? height;

  const SchoolHomeModeActionCard({
    super.key,
    required this.schoolId,
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.startColor,
    required this.endColor,
    this.height,
  });

  Future<void> _openModeSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TeacherAssignmentModeSheet(schoolId: schoolId, mode: mode);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = SchoolHomeActionCard(
      title: title,
      description: description,
      icon: icon,
      startColor: startColor,
      endColor: endColor,
      onTap: () => _openModeSheet(context, ref),
    );

    if (height == null) return card;
    return SizedBox(height: height, child: card);
  }
}
