import 'package:flutter/material.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';

class StudentClassificationStudentsListCard extends StatelessWidget {
  final List<StudentClusterRow> rows;

  const StudentClassificationStudentsListCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
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
            'Estudiantes clasificados',
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
                'No hay clasificaciones aun para este trimestre.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
              ),
            )
          else
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RowItem(row: row),
              ),
            ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final StudentClusterRow row;

  const _RowItem({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1EAF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.lastName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF0F2C4F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    row.firstName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1F476E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ClusterBadge(label: _label(row.clusterLabel)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  row.finalScore.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1F476E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${row.attendanceRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _label(String value) {
    if (value == 'alto_rendimiento') return 'Alto rendimiento';
    if (value == 'rendimiento_medio') return 'Rendimiento medio';
    if (value == 'en_riesgo') return 'En riesgo';
    return value;
  }
}

class _ClusterBadge extends StatelessWidget {
  final String label;

  const _ClusterBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFE0ECFA);
    Color fg = const Color(0xFF1F476E);
    if (label == 'Alto rendimiento') {
      bg = const Color(0xFFE6F7EC);
      fg = const Color(0xFF1E6A3F);
    } else if (label == 'En riesgo') {
      bg = const Color(0xFFFCE8E8);
      fg = const Color(0xFF9C2F2F);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
