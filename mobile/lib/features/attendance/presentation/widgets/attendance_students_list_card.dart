import 'package:flutter/material.dart';
import 'package:mobile/features/attendance/domain/domain.dart';

class AttendanceStudentsListCard extends StatelessWidget {
  final List<AttendanceGradebookRow> rows;
  final List<AttendanceStatusOption> statusOptions;
  final String? pendingKey;
  final bool disabled;
  final void Function(String studentId, AttendanceStatusOption status) onMark;

  const AttendanceStudentsListCard({
    super.key,
    required this.rows,
    required this.statusOptions,
    required this.pendingKey,
    required this.disabled,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
    final statusByTone = {
      'presente': _findStatus('Presente'),
      'licencia': _findStatus('Licencia'),
      'falta': _findStatus('Falta'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estudiantes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F2C4F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No hay estudiantes vinculados a este curso.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
              ),
            )
          else
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.lastName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF0F2C4F),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              row.firstName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF1F476E)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.statusName ?? 'Sin registrar',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF4B5563)),
                            ),
                          ],
                        ),
                      ),
                      _StatusDot(
                        tone: const Color(0xFF1F9D55),
                        bg: const Color(0xFFE4F7EC),
                        selected: row.statusId == statusByTone['presente']?.id,
                        loading:
                            pendingKey ==
                            '${row.studentId}:${statusByTone['presente']?.id}',
                        onTap: disabled || statusByTone['presente'] == null
                            ? null
                            : () => onMark(
                                row.studentId,
                                statusByTone['presente']!,
                              ),
                      ),
                      const SizedBox(width: 6),
                      _StatusDot(
                        tone: const Color(0xFFE0A100),
                        bg: const Color(0xFFFFF5D8),
                        selected: row.statusId == statusByTone['licencia']?.id,
                        loading:
                            pendingKey ==
                            '${row.studentId}:${statusByTone['licencia']?.id}',
                        onTap: disabled || statusByTone['licencia'] == null
                            ? null
                            : () => onMark(
                                row.studentId,
                                statusByTone['licencia']!,
                              ),
                      ),
                      const SizedBox(width: 6),
                      _StatusDot(
                        tone: const Color(0xFFD64545),
                        bg: const Color(0xFFFDE2E2),
                        selected: row.statusId == statusByTone['falta']?.id,
                        loading:
                            pendingKey ==
                            '${row.studentId}:${statusByTone['falta']?.id}',
                        onTap: disabled || statusByTone['falta'] == null
                            ? null
                            : () =>
                                  onMark(row.studentId, statusByTone['falta']!),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  AttendanceStatusOption? _findStatus(String name) {
    for (final status in statusOptions) {
      if (status.name.toLowerCase() == name.toLowerCase()) return status;
    }
    return null;
  }
}

class _StatusDot extends StatelessWidget {
  final Color tone;
  final Color bg;
  final bool selected;
  final bool loading;
  final VoidCallback? onTap;

  const _StatusDot({
    required this.tone,
    required this.bg,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFF1E3A5F),
                    ),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: selected ? 14 : 10,
                    height: selected ? 14 : 10,
                    decoration: BoxDecoration(
                      color: selected ? tone : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected ? tone : const Color(0xFFC7DBF1),
                        width: 1.5,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
