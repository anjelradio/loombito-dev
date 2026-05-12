import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/providers.dart';
import 'package:mobile/features/evaluations/presentation/widgets/term_averages/term_average_detail_sheet.dart';
import 'package:mobile/features/evaluations/presentation/widgets/term_averages/term_average_students_list_card.dart';
import 'package:mobile/features/evaluations/presentation/widgets/term_averages/term_average_summary_card.dart';
import 'package:mobile/features/shared/shared.dart';

class TermAveragesScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String assignmentId;

  const TermAveragesScreen({
    super.key,
    required this.schoolId,
    required this.assignmentId,
  });

  @override
  ConsumerState<TermAveragesScreen> createState() => _TermAveragesScreenState();
}

class _TermAveragesScreenState extends ConsumerState<TermAveragesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(termAveragesProvider.notifier)
          .load(widget.schoolId, widget.assignmentId),
    );
  }

  void _showInfo(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade800 : const Color(0xFF1F476E),
      ),
    );
  }

  Future<void> _onCalculate() async {
    final state = ref.read(termAveragesProvider);
    if (state.selectedTermId.isEmpty || state.isCalculating) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Calcular promedios',
        description:
            '¿Estas seguro de que quieres calcular los promedios del trimestre seleccionado?',
        confirmText: 'Calcular',
      ),
    );

    if (confirmed != true) return;

    final result = await ref
        .read(termAveragesProvider.notifier)
        .calculateSelectedTerm();
    if (!mounted) return;
    if (result == null) {
      _showInfo('No se pudieron calcular los promedios.', error: true);
      return;
    }
    _showInfo(
      'Promedios calculados para ${result.processedStudents} estudiantes.',
    );
  }

  void _openDetail(StudentTermAverageRow row) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TermAverageDetailSheet(row: row),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(termAveragesProvider);
    final selectedTerm = state.selectedTerm;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: ModalPageFabButton(
        onTap: _onCalculate,
        text: state.isCalculating ? 'Calculando...' : 'Calcular',
        icon: Icons.calculate_rounded,
      ),
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
                      child: Text(
                        'Promedios trimestrales',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF0F2C4F),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        TermAverageSummaryCard(
                          termOptions: state.termOptions,
                          selectedTermId: state.selectedTermId,
                          studentsCount: state.rows.length,
                          onSelectTerm: (termId) {
                            ref
                                .read(termAveragesProvider.notifier)
                                .load(
                                  widget.schoolId,
                                  widget.assignmentId,
                                  selectedTermId: termId,
                                  forceRefresh: true,
                                );
                          },
                        ),
                        const SizedBox(height: 12),
                        TermAverageStudentsListCard(
                          rows: state.rows,
                          onTapRow: _openDetail,
                        ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                if (!state.isLoading && selectedTerm == null)
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
