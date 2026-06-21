import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceDonutChart extends StatelessWidget {
  final int presences;
  final int absences;
  final int licenses;
  final double percentage;

  const AttendanceDonutChart({
    super.key,
    required this.presences,
    required this.absences,
    required this.licenses,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = presences > 0 || absences > 0 || licenses > 0;
    
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
          Text(
            'Asistencia Global',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF1F4D7D),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Sin registros de asistencia aún',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 55,
                      startDegreeOffset: -90,
                      sections: [
                        if (presences > 0)
                          PieChartSectionData(
                            color: const Color(0xFF2E7D32),
                            value: presences.toDouble(),
                            title: '$presences',
                            radius: 18,
                            titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        if (absences > 0)
                          PieChartSectionData(
                            color: const Color(0xFF9F2D2D),
                            value: absences.toDouble(),
                            title: '$absences',
                            radius: 18,
                            titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        if (licenses > 0)
                          PieChartSectionData(
                            color: const Color(0xFFD99036),
                            value: licenses.toDouble(),
                            title: '$licenses',
                            radius: 18,
                            titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF0F2C4F),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          'Presente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF4C6480),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend(context, 'Presencias', const Color(0xFF2E7D32)),
              _buildLegend(context, 'Faltas', const Color(0xFF9F2D2D)),
              _buildLegend(context, 'Licencias', const Color(0xFFD99036)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF35597E),
              ),
        ),
      ],
    );
  }
}
