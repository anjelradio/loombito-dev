import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/students/domain/domain.dart';
import 'package:mobile/features/reports/presentation/providers/student_boletin_provider.dart';

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                        Consumer(
                          builder: (context, ref, child) {
                            final boletinState = ref.watch(studentBoletinProvider);
                            final isLoading = boletinState.isLoading;

                            return _ActionCard(
                              title: 'Boletín',
                              subtitle: isLoading ? 'Descargando...' : 'Descargar reporte PDF',
                              icon: isLoading ? Icons.hourglass_empty : Icons.picture_as_pdf_outlined,
                              startColor: const Color(0xFF6A2A2A),
                              endColor: const Color(0xFF9B4A38),
                              onTap: isLoading
                                  ? () {}
                                  : () async {
                                      final studentName = '${widget.student.lastName} ${widget.student.firstName}'.trim();
                                      await ref.read(studentBoletinProvider.notifier).downloadBoletin(widget.student.id, studentName);
                                      if (context.mounted && ref.read(studentBoletinProvider).hasError) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Error al descargar el boletín')),
                                        );
                                      }
                                    },
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Deudas',
                          subtitle: 'Consultar deudas y pagar',
                          icon: Icons.receipt_long_outlined,
                          startColor: const Color(0xFFC75D5D),
                          endColor: const Color(0xFFD67777),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push(
                              '/schools/${widget.student.schoolId}/students/${widget.student.id}/debts',
                              extra: {
                                'studentName': '${widget.student.lastName} ${widget.student.firstName}'.trim(),
                              },
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Pagos',
                          subtitle: 'Historial de pagos',
                          icon: Icons.history_rounded,
                          startColor: const Color(0xFFD99036),
                          endColor: const Color(0xFFE4A452),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push(
                              '/schools/${widget.student.schoolId}/students/${widget.student.id}/payments',
                              extra: {
                                'studentName': '${widget.student.lastName} ${widget.student.firstName}'.trim(),
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 10) / 2;
                        final itemHeight = itemWidth / 1.35;
                        return SizedBox(
                          width: double.infinity,
                          height: itemHeight,
                          child: _ActionCard(
                            title: 'Rendimiento',
                            subtitle: 'Estadísticas e Inteligencia Artificial',
                            icon: Icons.auto_graph_rounded,
                            startColor: const Color(0xFF4C2B7A),
                            endColor: const Color(0xFF6B3C9E),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push(
                                '/schools/${widget.student.schoolId}/students/${widget.student.id}/performance',
                                extra: {
                                  'studentName': '${widget.student.lastName} ${widget.student.firstName}'.trim(),
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
