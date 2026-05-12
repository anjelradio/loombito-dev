import 'package:flutter/material.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';

class TermAverageDetailSheet extends StatelessWidget {
  final StudentTermAverageRow row;

  const TermAverageDetailSheet({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8D5E3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${row.firstName} ${row.lastName}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF1F4D7D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _Metric(label: 'Saber', value: _score(row.saberScore)),
            _Metric(label: 'Hacer', value: _score(row.hacerScore)),
            _Metric(label: 'Ser', value: _score(row.serScore)),
            _Metric(
              label: 'Autoevaluacion',
              value: _score(row.autoevaluacionScore),
            ),
            const Divider(height: 18),
            _Metric(
              label: 'Promedio final',
              value: _score(row.finalScore),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  String _score(double? value) =>
      value == null ? 'Sin calcular' : value.toStringAsFixed(2);
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Metric({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF315A85),
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF1F4D7D),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
