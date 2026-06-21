import 'package:flutter/material.dart';

class CurrentAverageCard extends StatelessWidget {
  final double average;

  const CurrentAverageCard({super.key, required this.average});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5E3F3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promedio Actual General',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF1F4D7D),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                average.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0F2C4F),
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1F8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFF35597E), size: 24),
          ),
        ],
      ),
    );
  }
}
