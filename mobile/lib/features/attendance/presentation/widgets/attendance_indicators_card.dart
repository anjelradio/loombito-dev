import 'package:flutter/material.dart';

class AttendanceIndicatorsCard extends StatelessWidget {
  final int totalSessions;
  final int closedSessions;

  const AttendanceIndicatorsCard({
    super.key,
    required this.totalSessions,
    required this.closedSessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Sesiones',
              value: '$totalSessions',
              color: const Color(0xFF1F476E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Metric(
              label: 'Finalizadas',
              value: '$closedSessions',
              color: const Color.fromARGB(255, 31, 110, 69),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
