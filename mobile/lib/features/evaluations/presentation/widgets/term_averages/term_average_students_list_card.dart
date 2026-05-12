import 'package:flutter/material.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';

class TermAverageStudentsListCard extends StatelessWidget {
  final List<StudentTermAverageRow> rows;
  final void Function(StudentTermAverageRow row) onTapRow;

  const TermAverageStudentsListCard({
    super.key,
    required this.rows,
    required this.onTapRow,
  });

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
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RowItem(row: row, onTap: () => onTapRow(row)),
              ),
            ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final StudentTermAverageRow row;
  final VoidCallback onTap;

  const _RowItem({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final finalScore = row.status == 'calculado' && row.finalScore != null
        ? row.finalScore!.toStringAsFixed(2)
        : 'Sin calcular';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                finalScore,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1F476E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
