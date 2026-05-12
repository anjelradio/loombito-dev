import 'package:flutter/material.dart';
import 'package:mobile/features/students/domain/domain.dart';

import 'evaluation_student_list_item.dart';

class EvaluationStudentsListCard extends StatelessWidget {
  final List<StudentGradebookRow> rows;
  final void Function(StudentGradebookRow row) onTapRow;

  const EvaluationStudentsListCard({
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
                'No hay estudiantes vinculados a esta evaluacion.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
              ),
            )
          else
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: EvaluationStudentListItem(
                  row: row,
                  onTap: () => onTapRow(row),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
