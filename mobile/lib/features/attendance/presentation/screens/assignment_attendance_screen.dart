import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/attendance/domain/domain.dart';
import 'package:mobile/features/attendance/presentation/providers/providers.dart';
import 'package:mobile/features/attendance/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';

class AssignmentAttendanceScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String assignmentId;

  const AssignmentAttendanceScreen({
    super.key,
    required this.schoolId,
    required this.assignmentId,
  });

  @override
  ConsumerState<AssignmentAttendanceScreen> createState() =>
      _AssignmentAttendanceScreenState();
}

class _AssignmentAttendanceScreenState
    extends ConsumerState<AssignmentAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(assignmentAttendanceProvider.notifier)
          .load(widget.schoolId, widget.assignmentId, perPage: 12),
    );
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

  @override
  Widget build(BuildContext context) {
    ref.listen(assignmentAttendanceProvider, (previous, next) {
      final msg = next.errorMessages.isNotEmpty
          ? next.errorMessages.first
          : null;
      final prevMsg = previous != null && previous.errorMessages.isNotEmpty
          ? previous.errorMessages.first
          : null;
      if (msg != null && prevMsg != msg) {
        _showInfo(context, msg);
      }
    });

    final state = ref.watch(assignmentAttendanceProvider);
    final sessions = state.sessions.sessions;
    final closedSessions = sessions.where((s) => s.isClosed).length;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: RegisterAttendanceSessionFabButton(
        schoolId: widget.schoolId,
        assignmentId: widget.assignmentId,
        onCreated: () {
          ref
              .read(assignmentAttendanceProvider.notifier)
              .load(
                widget.schoolId,
                widget.assignmentId,
                perPage: 12,
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
                        'Asistencias',
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
                        AttendanceIndicatorsCard(
                          totalSessions: sessions.length,
                          closedSessions: closedSessions,
                        ),
                        const SizedBox(height: 12),
                        AttendanceSessionsListCard(
                          sessions: sessions,
                          onTapSession: _onTapSession,
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

  Future<void> _onTapSession(AttendanceSession session) async {
    final changed = await context.push<bool>(
      '/schools/${widget.schoolId}/teacher/asistir/${session.id}',
    );
    if (changed == true && mounted) {
      ref
          .read(assignmentAttendanceProvider.notifier)
          .load(
            widget.schoolId,
            widget.assignmentId,
            perPage: 12,
            forceRefresh: true,
          );
    }
  }
}
