import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/providers.dart';
import 'package:mobile/features/evaluations/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:mobile/features/students/students.dart';

class EvaluateEvaluationScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String evaluationId;

  const EvaluateEvaluationScreen({
    super.key,
    required this.schoolId,
    required this.evaluationId,
  });

  @override
  ConsumerState<EvaluateEvaluationScreen> createState() =>
      _EvaluateEvaluationScreenState();
}

class _EvaluateEvaluationScreenState
    extends ConsumerState<EvaluateEvaluationScreen> {
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(evaluationDetailProvider.notifier)
          .load(widget.schoolId, widget.evaluationId);
      ref
          .read(evaluationGradebookProvider.notifier)
          .load(widget.schoolId, widget.evaluationId);
    });
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1F476E),
      ),
    );
  }

  Future<void> _onDeleteEvaluation(Evaluation evaluation) async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: 'Eliminar evaluacion',
        description: '¿Estas seguro de eliminar "${evaluation.name}"?',
        confirmText: 'Eliminar',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref
          .read(evaluationRepositoryProvider)
          .deleteEvaluation(widget.schoolId, widget.evaluationId);
      if (!mounted) return;
      _showInfo(context, 'Evaluacion eliminada correctamente');
      if (context.canPop()) {
        context.pop(true);
      }
    } catch (_) {
      if (!mounted) return;
      _showInfo(context, 'No se pudo eliminar la evaluacion.');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _onTapStudentRow(StudentGradebookRow row) async {
    final detailState = ref.read(evaluationDetailProvider);
    final evaluation = detailState.evaluation;
    if (evaluation == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => UpsertGradeDialog(
        schoolId: widget.schoolId,
        evaluationId: widget.evaluationId,
        row: row,
        onSaved: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Calificacion guardada correctamente'),
              backgroundColor: Color.fromARGB(255, 31, 110, 69),
            ),
          );
        },
      ),
    );

    if (saved == true && mounted) {
      ref
          .read(evaluationGradebookProvider.notifier)
          .load(widget.schoolId, widget.evaluationId, forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(evaluationDetailProvider);
    final studentsState = ref.watch(evaluationGradebookProvider);

    ref.listen(evaluationDetailProvider, (previous, next) {
      final msg = next.errorMessages.isNotEmpty
          ? next.errorMessages.first
          : null;
      if (msg != null) _showInfo(context, msg);
    });
    ref.listen(evaluationGradebookProvider, (previous, next) {
      final msg = next.errorMessages.isNotEmpty
          ? next.errorMessages.first
          : null;
      if (msg != null) _showInfo(context, msg);
    });

    final isLoading = detailState.isLoading || studentsState.isLoading;
    final evaluation = detailState.evaluation;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: evaluation == null
          ? null
          : EditEvaluationFabButton(
              schoolId: widget.schoolId,
              evaluation: evaluation,
              typeOptions: detailState.typeOptions,
              termOptions: detailState.termOptions,
              onUpdated: () {
                ref
                    .read(evaluationDetailProvider.notifier)
                    .load(
                      widget.schoolId,
                      widget.evaluationId,
                      forceRefresh: true,
                    );
              },
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
                        'Evaluar',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF0F2C4F),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    AppCircleIconButton(
                      onPressed: evaluation == null || _isDeleting
                          ? () {}
                          : () => _onDeleteEvaluation(evaluation),
                      icon: Icons.delete_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (evaluation == null)
                  const Expanded(
                    child: Center(child: Text('No se encontro la evaluacion.')),
                  )
                else
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        EvaluateEvaluationInfoCard(
                          schoolId: widget.schoolId,
                          evaluation: evaluation,
                          onFinalized: () {
                            ref
                                .read(evaluationDetailProvider.notifier)
                                .load(
                                  widget.schoolId,
                                  widget.evaluationId,
                                  forceRefresh: true,
                                );
                            ref
                                .read(evaluationGradebookProvider.notifier)
                                .load(
                                  widget.schoolId,
                                  widget.evaluationId,
                                  forceRefresh: true,
                                );
                          },
                          onError: (message) => _showInfo(context, message),
                        ),
                        const SizedBox(height: 12),
                        EvaluationStudentsListCard(
                          rows: studentsState.rows,
                          onTapRow: _onTapStudentRow,
                        ),
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
