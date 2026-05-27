import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/students/domain/domain.dart';

class StudentActionsSheet extends StatefulWidget {
  final LinkedStudent student;

  const StudentActionsSheet({super.key, required this.student});

  @override
  State<StudentActionsSheet> createState() => _StudentActionsSheetState();
}

class _StudentActionsSheetState extends State<StudentActionsSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.76,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAFF), Color(0xFFEEF4FB)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.student.lastName} ${widget.student.firstName}'.trim(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF0F2C4F),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(Icons.close_rounded, color: Color(0xFF1F476E), size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona una opcion para este estudiante',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF4C6480)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _ActionCard(
                    title: 'Licencias',
                    subtitle: 'Solicitar y revisar historial',
                    icon: Icons.assignment_turned_in_outlined,
                    startColor: const Color(0xFF1A4E63),
                    endColor: const Color(0xFF2B6F8B),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(
                        '/schools/${widget.student.schoolId}/students/${widget.student.id}/licenses',
                        extra: {
                          'studentName': '${widget.student.lastName} ${widget.student.firstName}'.trim(),
                        },
                      );
                    },
                  ),
                  _ActionCard(
                    title: 'Asistencias',
                    subtitle: 'Proximamente',
                    icon: Icons.how_to_reg_rounded,
                    startColor: const Color(0xFF2E5B35),
                    endColor: const Color(0xFF3F7A61),
                    onTap: () {},
                  ),
                  _ActionCard(
                    title: 'Evaluaciones',
                    subtitle: 'Proximamente',
                    icon: Icons.fact_check_outlined,
                    startColor: const Color(0xFF0F2C4F),
                    endColor: const Color(0xFF1F476E),
                    onTap: () {},
                  ),
                  _ActionCard(
                    title: 'Promedios',
                    subtitle: 'Proximamente',
                    icon: Icons.bar_chart_rounded,
                    startColor: const Color(0xFF6A2A2A),
                    endColor: const Color(0xFF9B4A38),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.startColor,
    required this.endColor,
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor, endColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
