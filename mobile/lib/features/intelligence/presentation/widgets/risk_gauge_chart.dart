import 'package:flutter/material.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';

class RiskGaugeChart extends StatelessWidget {
  final StudentPredictionsData predictions;

  const RiskGaugeChart({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final hasPredictions = predictions.failureProbability != null;
    
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
              const Icon(Icons.psychology_alt_rounded, color: Color(0xFF4C2B7A), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Proyección de Rendimiento (IA)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF1F4D7D),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasPredictions)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aún no hay predicciones calculadas para este alumno',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            Text(
              'Riesgo de Reprobación Global',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF35597E),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            _buildRiskIndicator(context, predictions.failureProbability!),
            const SizedBox(height: 16),
            if (predictions.clusterLabel != null)
              _buildClusterBadge(context, predictions.clusterLabel!),
            const SizedBox(height: 16),
            _buildScoreInfo(context, 'Nota Proyectada a Fin de Año', predictions.projectedFinalScore),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(BuildContext context, double probability) {
    final riskPercent = (probability * 100).clamp(0, 100).toInt();
    
    Color riskColor;
    String riskText;
    if (probability < 0.3) {
      riskColor = const Color(0xFF2E7D32);
      riskText = 'Bajo';
    } else if (probability < 0.7) {
      riskColor = const Color(0xFFD99036);
      riskText = 'Medio';
    } else {
      riskColor = const Color(0xFF9F2D2D);
      riskText = 'Alto';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              riskText, 
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: riskColor, 
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$riskPercent%', 
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: riskColor, 
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: probability,
            minHeight: 10,
            backgroundColor: const Color(0xFFEAF1F8),
            valueColor: AlwaysStoppedAnimation<Color>(riskColor),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreInfo(BuildContext context, String title, double? score) {
    if (score == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5E3F3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF35597E),
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF0F2C4F),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildClusterBadge(BuildContext context, String cluster) {
    String title = 'Estudiante';
    String subtitle = 'Clasificación pendiente';
    IconData icon = Icons.group_work_rounded;
    Color color = const Color(0xFF35597E);
    Color bgColor = const Color(0xFFF0F5FA);

    if (cluster == 'alto_rendimiento') {
      title = 'Alto Rendimiento';
      subtitle = '¡Felicidades! Excelente desempeño.';
      icon = Icons.emoji_events_rounded;
      color = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
    } else if (cluster == 'rendimiento_medio') {
      title = 'Rendimiento Promedio';
      subtitle = 'Va por buen camino, pero puede mejorar.';
      icon = Icons.trending_up_rounded;
      color = const Color(0xFFD99036);
      bgColor = const Color(0xFFFFF8E1);
    } else if (cluster == 'en_riesgo') {
      title = 'En Riesgo';
      subtitle = 'Requiere atención inmediata y apoyo.';
      icon = Icons.warning_rounded;
      color = const Color(0xFF9F2D2D);
      bgColor = const Color(0xFFFFEBEE);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
