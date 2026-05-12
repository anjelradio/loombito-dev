import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/evaluations/domain/domain.dart';
import 'package:mobile/features/evaluations/presentation/providers/providers.dart';
import 'package:mobile/features/evaluations/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';

class AssignmentEvaluationsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String assignmentId;

  const AssignmentEvaluationsScreen({
    super.key,
    required this.schoolId,
    required this.assignmentId,
  });

  @override
  ConsumerState<AssignmentEvaluationsScreen> createState() =>
      _AssignmentEvaluationsScreenState();
}

class _AssignmentEvaluationsScreenState
    extends ConsumerState<AssignmentEvaluationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(assignmentEvaluationsProvider.notifier)
          .load(widget.schoolId, widget.assignmentId, perPage: 15),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(assignmentEvaluationsProvider, (previous, next) {
      final hasError = next.errorMessages.isNotEmpty;
      final previousError =
          previous != null && previous.errorMessages.isNotEmpty
          ? previous.errorMessages.first
          : null;
      final currentError = hasError ? next.errorMessages.first : null;

      if (!hasError || previousError == currentError) return;
      _showErrorSnackbar(context, currentError!);
    });

    final state = ref.watch(assignmentEvaluationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: RegisterEvaluationFabButton(
        schoolId: widget.schoolId,
        assignmentId: widget.assignmentId,
        typeOptions: state.typeOptions,
        termOptions: state.termOptions,
        onCreated: () {
          ref
              .read(assignmentEvaluationsProvider.notifier)
              .load(
                widget.schoolId,
                widget.assignmentId,
                perPage: 15,
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
                        'Evaluaciones',
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
                        const EvaluationIndicatorsCard(),
                        const SizedBox(height: 12),
                        EvaluationsListCard(
                          evaluations: state.evaluations.evaluations,
                          onTapEvaluation: (evaluation) async {
                            await _onTapEvaluation(context, evaluation);
                          },
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

  Future<void> _onTapEvaluation(
    BuildContext context,
    Evaluation evaluation,
  ) async {
    final deleted = await context.push<bool>(
      '/schools/${widget.schoolId}/teacher/evaluar/${evaluation.id}',
    );

    if (deleted == true && mounted) {
      ref
          .read(assignmentEvaluationsProvider.notifier)
          .load(
            widget.schoolId,
            widget.assignmentId,
            perPage: 15,
            forceRefresh: true,
          );
    }
  }
}
