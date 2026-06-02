import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/intelligence/presentation/providers/providers.dart';
import 'package:mobile/features/intelligence/presentation/widgets/widgets.dart';
import 'package:mobile/features/reports/reports.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentClassificationScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String assignmentId;

  const StudentClassificationScreen({
    super.key,
    required this.schoolId,
    required this.assignmentId,
  });

  @override
  ConsumerState<StudentClassificationScreen> createState() =>
      _StudentClassificationScreenState();
}

class _StudentClassificationScreenState
    extends ConsumerState<StudentClassificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(studentClassificationProvider.notifier)
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

  void _openReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceReportSheet(
        schoolId: widget.schoolId,
        assignmentId: widget.assignmentId,
        termId: ref.read(studentClassificationProvider).selectedTermId,
      ),
    );
  }

  Future<void> _onCalculate() async {
    final state = ref.read(studentClassificationProvider);
    if (state.selectedTermId.isEmpty || state.isCalculating) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Calcular clasificacion',
        description:
            '¿Estas seguro de que quieres recalcular la clasificacion del trimestre seleccionado?',
        confirmText: 'Calcular',
      ),
    );

    if (confirmed != true) return;

    final result = await ref
        .read(studentClassificationProvider.notifier)
        .recalculateSelectedTerm();
    if (!mounted) return;
    if (result == null) {
      _showInfo('No se pudo calcular la clasificacion.', error: true);
      return;
    }

    _showInfo(
      'Clasificacion calculada para ${result.processedStudents} estudiantes.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentClassificationProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: ModalPageFabButton(
        onTap: _onCalculate,
        text: state.isCalculating ? 'Calculando...' : 'Calcular',
        icon: Icons.psychology_alt_rounded,
      ),
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                        'Clasificacion',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF0F2C4F),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    AppCircleIconButton(
                      onPressed: _openReportSheet,
                      icon: Icons.description_outlined,
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
                        StudentClassificationSummaryCard(
                          termOptions: state.termOptions,
                          selectedTermId: state.selectedTermId,
                          snapshot: state.snapshot,
                          onSelectTerm: (termId) {
                            ref
                                .read(studentClassificationProvider.notifier)
                                .load(
                                  widget.schoolId,
                                  widget.assignmentId,
                                  selectedTermId: termId,
                                  forceRefresh: true,
                                );
                          },
                        ),
                        const SizedBox(height: 12),
                        StudentClassificationStudentsListCard(
                          rows: state.snapshot?.students ?? const [],
                        ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
