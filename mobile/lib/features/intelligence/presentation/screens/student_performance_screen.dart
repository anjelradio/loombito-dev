import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mobile/features/intelligence/presentation/providers/providers.dart';
import 'package:mobile/features/intelligence/presentation/widgets/attendance_donut_chart.dart';
import 'package:mobile/features/intelligence/presentation/widgets/risk_gauge_chart.dart';
import 'package:mobile/features/intelligence/presentation/widgets/subject_performance_card.dart';
import 'package:mobile/features/intelligence/presentation/widgets/current_average_card.dart';
import 'package:mobile/features/intelligence/domain/domain.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentPerformanceScreen extends ConsumerWidget {
  final String schoolId;
  final String studentId;
  final String studentName;

  const StudentPerformanceScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(
      studentStatisticsProvider((schoolId: schoolId, studentId: studentId)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppCircleIconButton(
                      onPressed: context.pop,
                      icon: Icons.arrow_back_ios_new_rounded,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rendimiento',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF0F2C4F),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            studentName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF35597E),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: performanceAsync.when(
                    data: (data) {
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          CurrentAverageCard(average: data.statistics.currentAverage),
                          const SizedBox(height: 12),
                          AttendanceDonutChart(
                            presences: data.statistics.totalPresences,
                            absences: data.statistics.totalAbsences,
                            licenses: data.statistics.totalLicenses,
                            percentage: data.statistics.attendancePercentage,
                          ),
                          const SizedBox(height: 12),
                          SubjectPerformanceCard(
                            strengths: data.statistics.strengths,
                            weaknesses: data.statistics.weaknesses,
                          ),
                          const SizedBox(height: 12),
                          RiskGaugeChart(predictions: data.predictions),
                        ],
                      );
                    },
                    loading: () => _buildLoadingSkeleton(),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFF9F2D2D), size: 40),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar rendimiento',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF9F2D2D),
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            CustomFilledButton(
                              text: 'Reintentar',
                              onPressed: () => ref.refresh(
                                studentStatisticsProvider((schoolId: schoolId, studentId: studentId)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.blueGrey.shade100,
        highlightColor: Colors.white,
        duration: const Duration(seconds: 2),
      ),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const CurrentAverageCard(average: 9.5),
          const SizedBox(height: 12),
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          SubjectPerformanceCard(
            strengths: [
              SubjectPerformance(subjectName: 'Matemáticas', average: 10.0),
              SubjectPerformance(subjectName: 'Física', average: 9.5),
            ],
            weaknesses: [
              SubjectPerformance(subjectName: 'Historia', average: 6.0),
            ],
          ),
          const SizedBox(height: 12),
          RiskGaugeChart(
            predictions: StudentPredictionsData(
              clusterLabel: 'alto_rendimiento',
              projectedFinalScore: 9.5,
              failureProbability: 0.05,
              calculatedAt: DateTime.now(),
            ),
          ),
        ],
      ),
    );
  }
}
