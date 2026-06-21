import 'package:flutter/material.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';

class SubjectPerformanceCard extends StatelessWidget {
  final List<SubjectPerformance> strengths;
  final List<SubjectPerformance> weaknesses;

  const SubjectPerformanceCard({
    super.key,
    required this.strengths,
    required this.weaknesses,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = strengths.isNotEmpty || weaknesses.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5E3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFD99036), size: 18),
              const SizedBox(width: 6),
              Text(
                'Fortalezas y Debilidades',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF1F4D7D),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (strengths.isNotEmpty) ...[
            Text(
              'Top Materias 🟢',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            ...strengths.map((s) => _buildSubjectRow(context, s, const Color(0xFF2E7D32))),
            const SizedBox(height: 16),
          ],
          if (weaknesses.isNotEmpty) ...[
            Text(
              'Necesita Atención 🔴',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9F2D2D),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            ...weaknesses.map((w) => _buildSubjectRow(context, w, const Color(0xFF9F2D2D))),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectRow(BuildContext context, SubjectPerformance subject, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              subject.subjectName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF35597E),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              subject.average.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
