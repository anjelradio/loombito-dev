import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/providers.dart';

class CommunicationModeSheet extends ConsumerStatefulWidget {
  final String schoolId;

  const CommunicationModeSheet({super.key, required this.schoolId});

  @override
  ConsumerState<CommunicationModeSheet> createState() => _CommunicationModeSheetState();
}

class _CommunicationModeSheetState extends ConsumerState<CommunicationModeSheet> {
  int _pageIndex = 0;
  TeacherCommunicationCourse? _selectedCourse;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teacherCommunicationCoursesProvider.notifier).load(widget.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(teacherCommunicationCoursesProvider);
    final studentsState = ref.watch(teacherCommunicationStudentsProvider);

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
            const Positioned.fill(child: IgnorePointer(child: _SheetGridLayer())),
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
                  pageIndex: _pageIndex,
                  selectedCourseName: _selectedCourse?.name,
                  onClose: () => Navigator.of(context).pop(),
                  onBack: () => setState(() => _pageIndex = 0),
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
                            key: const ValueKey('communication-courses-page'),
                            isLoading: courseState.isLoading,
                            courses: courseState.courses,
                            onTapCourse: (course) {
                              ref
                                  .read(teacherCommunicationStudentsProvider.notifier)
                                  .load(widget.schoolId, course.id, forceRefresh: true);
                              setState(() {
                                _selectedCourse = course;
                                _pageIndex = 1;
                              });
                            },
                          )
                        : _StudentsPage(
                            key: const ValueKey('communication-students-page'),
                            isLoading: studentsState.isLoading,
                            students: studentsState.students,
                            onTapStudent: (student) {
                              final selectedCourse = _selectedCourse;
                              if (selectedCourse == null) return;
                              Navigator.of(context).pop();
                              context.push(
                                '/schools/${widget.schoolId}/teacher/comunicados/${selectedCourse.id}/${student.id}',
                                extra: {
                                  'courseName': selectedCourse.name,
                                  'studentName': student.fullName,
                                },
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
  final int pageIndex;
  final String? selectedCourseName;
  final VoidCallback onClose;
  final VoidCallback onBack;

  const _Header({
    required this.pageIndex,
    required this.selectedCourseName,
    required this.onClose,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isStudentsPage = pageIndex == 1;
    return Row(
      children: [
        if (isStudentsPage)
          _HeaderIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        if (isStudentsPage) const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStudentsPage ? (selectedCourseName ?? 'Estudiantes') : 'Comunicados',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0F2C4F),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                isStudentsPage ? 'Selecciona un estudiante' : 'Selecciona un curso',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF4C6480)),
              ),
            ],
          ),
        ),
        if (!isStudentsPage) _HeaderIconButton(icon: Icons.close_rounded, onTap: onClose),
      ],
    );
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
  final bool isLoading;
  final List<TeacherCommunicationCourse> courses;
  final void Function(TeacherCommunicationCourse course) onTapCourse;

  const _CoursesPage({
    super.key,
    required this.isLoading,
    required this.courses,
    required this.onTapCourse,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    if (courses.isEmpty) return const _EmptyCard(message: 'Aun no tienes cursos disponibles para comunicados.');

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _SelectableTile(title: course.name, subtitle: 'Ver estudiantes', onTap: () => onTapCourse(course));
      },
    );
  }
}

class _StudentsPage extends StatelessWidget {
  final bool isLoading;
  final List<TeacherCommunicationStudent> students;
  final void Function(TeacherCommunicationStudent student) onTapStudent;

  const _StudentsPage({
    super.key,
    required this.isLoading,
    required this.students,
    required this.onTapStudent,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    if (students.isEmpty) return const _EmptyCard(message: 'No hay estudiantes activos en este curso.');

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = students[index];
        return _SelectableTile(title: student.fullName, subtitle: 'Ver comunicados', onTap: () => onTapStudent(student));
      },
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SelectableTile({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E4A75).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF1F476E),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F2C4F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4C6480)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF315A85)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
    );
  }
}
