import 'package:flutter/material.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/shared/shared.dart';

class TermAverageSummaryCard extends StatelessWidget {
  final List<TermAverageOption> termOptions;
  final String selectedTermId;
  final int studentsCount;
  final void Function(String termId) onSelectTerm;

  const TermAverageSummaryCard({
    super.key,
    required this.termOptions,
    required this.selectedTermId,
    required this.studentsCount,
    required this.onSelectTerm,
  });

  @override
  Widget build(BuildContext context) {
    TermAverageOption? selectedTerm;
    for (final term in termOptions) {
      if (term.id == selectedTermId) {
        selectedTerm = term;
        break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del trimestre',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F2C4F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SelectableChips(
            options: termOptions
                .map(
                  (option) => SelectableChipOption(
                    value: option.id,
                    label: option.name,
                  ),
                )
                .toList(),
            selectedValues: selectedTermId.isEmpty
                ? const []
                : [selectedTermId],
            onChange: (values) {
              if (values.isNotEmpty) onSelectTerm(values.first);
            },
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Trimestre', value: selectedTerm?.name ?? '--'),
          _InfoRow(label: 'Estudiantes', value: '$studentsCount'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF1F476E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
