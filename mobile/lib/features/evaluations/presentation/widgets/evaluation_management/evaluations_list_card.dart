import 'package:flutter/material.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'evaluation_list_item_card.dart';

class EvaluationsListCard extends StatelessWidget {
  final List<Evaluation> evaluations;
  final void Function(Evaluation evaluation) onTapEvaluation;

  const EvaluationsListCard({
    super.key,
    required this.evaluations,
    required this.onTapEvaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listado de evaluaciones',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F2C4F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (evaluations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Aun no hay evaluaciones registradas para esta materia.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                ),
              ),
            )
          else
            ...evaluations.map(
              (evaluation) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: EvaluationListItemCard(
                  evaluation: evaluation,
                  onTap: () => onTapEvaluation(evaluation),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
