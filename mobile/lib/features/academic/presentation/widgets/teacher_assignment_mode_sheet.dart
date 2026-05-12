import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/academic/domain/domain.dart';
import 'package:mobile/features/academic/presentation/providers/providers.dart';
import 'package:mobile/features/academic/presentation/widgets/teacher_assignment_mode_sheet/teacher_assignment_course_tile.dart';
import 'package:mobile/features/academic/presentation/widgets/teacher_assignment_mode_sheet/teacher_assignment_subject_tile.dart';
import 'package:mobile/features/shared/shared.dart';

class TeacherAssignmentModeSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final TeacherAssignmentMode mode;

  const TeacherAssignmentModeSheet({
    super.key,
    required this.schoolId,
    required this.mode,
  });

  @override
  ConsumerState<TeacherAssignmentModeSheet> createState() =>
      _TeacherAssignmentModeSheetState();
}

class _TeacherAssignmentModeSheetState
    extends ConsumerState<TeacherAssignmentModeSheet> {
  int _pageIndex = 0;
  TeacherAssignmentCourseGroup? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherAssignmentsProvider);
    final groups = state.groups;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.84,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAFF), Color(0xFFEEF4FB)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: _SheetGridLayer()),
            ),
            Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8D5E3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                _Header(
                  mode: widget.mode,
                  pageIndex: _pageIndex,
                  selectedCourseName: _selectedGroup?.courseName,
                  onClose: () => Navigator.of(context).pop(),
                  onBack: () {
                    setState(() {
                      _pageIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.12, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _pageIndex == 0
                        ? _CoursesPage(
                            key: const ValueKey('courses-page'),
                            groups: groups,
                            isLoading: state.isLoading,
                            onSelectGroup: (group) {
                              setState(() {
                                _selectedGroup = group;
                                _pageIndex = 1;
                              });
                            },
                          )
                        : _SubjectsPage(
                            key: const ValueKey('subjects-page'),
                            group: _selectedGroup,
                            onBack: () {},
                            onTapSubject: (subject) {
                              Navigator.of(context).pop();
                              context.push(
                                '/schools/${widget.schoolId}/teacher/${widget.mode.routeSegment}/${subject.assignmentId}',
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TeacherAssignmentMode mode;
  final int pageIndex;
  final String? selectedCourseName;
  final VoidCallback onClose;
  final VoidCallback onBack;

  const _Header({
    required this.mode,
    required this.pageIndex,
    required this.selectedCourseName,
    required this.onClose,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isSubjectsPage = pageIndex == 1;
    final mainTitle = isSubjectsPage
        ? (selectedCourseName?.trim().isNotEmpty == true
              ? selectedCourseName!
              : 'Seleccionar materia')
        : _modeTitle(mode);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSubjectsPage) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _HeaderIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0F2C4F),
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isSubjectsPage
                    ? 'Selecciona alguna materia'
                    : 'Selecciona un curso',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4C6480),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isSubjectsPage)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _HeaderIconButton(icon: Icons.close_rounded, onTap: onClose),
          ),
      ],
    );
  }

  String _modeTitle(TeacherAssignmentMode mode) {
    final normalized = mode.title.trim().toLowerCase();
    if (normalized.contains('asistencia')) return 'Asistencias';
    if (normalized.contains('promedio')) return 'Promedios';
    if (normalized.contains('evaluacion')) return 'Evaluaciones';
    return mode.title;
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(icon, color: const Color(0xFF1F476E), size: 22),
      ),
    );
  }
}

class _SheetGridLayer extends StatelessWidget {
  const _SheetGridLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _SheetGridPainter())),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF6FAFF).withValues(alpha: 0.18),
                  const Color(0xFFF1F6FD).withValues(alpha: 0.62),
                  const Color(0xFFEEF4FB).withValues(alpha: 0.92),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 26.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF1E4A75).withValues(alpha: 0.09);

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoursesPage extends StatelessWidget {
  final List<TeacherAssignmentCourseGroup> groups;
  final bool isLoading;
  final void Function(TeacherAssignmentCourseGroup group) onSelectGroup;

  const _CoursesPage({
    super.key,
    required this.groups,
    required this.isLoading,
    required this.onSelectGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (groups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8E5F2)),
        ),
        child: Text(
          'Aun no tienes asignaciones activas en esta escuela.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final group = groups[index];
        return TeacherAssignmentCourseTile(
          group: group,
          onTap: () => onSelectGroup(group),
        );
      },
    );
  }
}

class _SubjectsPage extends StatelessWidget {
  final TeacherAssignmentCourseGroup? group;
  final VoidCallback onBack;
  final void Function(TeacherAssignmentSubject subject) onTapSubject;

  const _SubjectsPage({
    super.key,
    required this.group,
    required this.onBack,
    required this.onTapSubject,
  });

  @override
  Widget build(BuildContext context) {
    final selectedGroup = group;
    if (selectedGroup == null) {
      return Center(
        child: CustomFilledButton(text: 'Volver', onPressed: onBack),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: selectedGroup.subjects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final subject = selectedGroup.subjects[index];
              return TeacherAssignmentSubjectTile(
                subject: subject,
                onTap: () => onTapSubject(subject),
              );
            },
          ),
        ),
      ],
    );
  }
}
