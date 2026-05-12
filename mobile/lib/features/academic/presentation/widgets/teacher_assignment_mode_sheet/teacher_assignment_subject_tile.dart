import 'package:flutter/material.dart';
import 'package:mobile/features/academic/domain/domain.dart';
import 'package:mobile/features/academic/presentation/widgets/teacher_assignment_mode_sheet/teacher_assignment_tile_icon.dart';

class TeacherAssignmentSubjectTile extends StatelessWidget {
  final TeacherAssignmentSubject subject;
  final VoidCallback onTap;

  const TeacherAssignmentSubjectTile({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF9FCFF), Color(0xFFE8F1FC)],
            ),
            border: Border.all(color: const Color(0xFFD4E3F2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2C4F).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
          child: Row(
            children: [
              const TeacherAssignmentTileIcon(icon: Icons.menu_book_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0F2C4F),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                color: Color(0xFF1F476E),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
