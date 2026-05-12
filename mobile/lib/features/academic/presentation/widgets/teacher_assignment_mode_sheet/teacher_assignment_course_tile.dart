import 'package:flutter/material.dart';
import 'package:mobile/features/academic/domain/domain.dart';
import 'package:mobile/features/academic/presentation/widgets/teacher_assignment_mode_sheet/teacher_assignment_tile_icon.dart';

class TeacherAssignmentCourseTile extends StatelessWidget {
  final TeacherAssignmentCourseGroup group;
  final VoidCallback onTap;

  const TeacherAssignmentCourseTile({
    super.key,
    required this.group,
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
              colors: [Color(0xFFFFFFFF), Color(0xFFF2F7FD)],
            ),
            border: Border.all(color: const Color(0xFFD4E3F2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2C4F).withValues(alpha: 0.11),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          child: Row(
            children: [
              const TeacherAssignmentTileIcon(icon: Icons.grid_view_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  group.courseName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0F2C4F),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EFF8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${group.subjects.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF35597E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF1F476E)),
            ],
          ),
        ),
      ),
    );
  }
}
