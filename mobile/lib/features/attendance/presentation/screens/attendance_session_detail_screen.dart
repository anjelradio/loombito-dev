import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/attendance/domain/domain.dart';
import 'package:mobile/features/attendance/presentation/providers/providers.dart';
import 'package:mobile/features/attendance/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';

class AttendanceSessionDetailScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String sessionId;

  const AttendanceSessionDetailScreen({
    super.key,
    required this.schoolId,
    required this.sessionId,
  });

  @override
  ConsumerState<AttendanceSessionDetailScreen> createState() =>
      _AttendanceSessionDetailScreenState();
}

class _AttendanceSessionDetailScreenState
    extends ConsumerState<AttendanceSessionDetailScreen> {
  bool _isDeleting = false;
  bool _isFinalizing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(attendanceSessionDetailProvider.notifier)
          .load(widget.schoolId, widget.sessionId),
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

  Future<void> _onDelete(AttendanceSession session) async {
    if (_isDeleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: 'Eliminar sesion',
        description: '¿Estas seguro de eliminar "${session.name}"?',
        confirmText: 'Eliminar',
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref
          .read(attendanceRepositoryProvider)
          .deleteSession(widget.schoolId, widget.sessionId);
      if (!mounted) return;
      _showInfo('Sesion eliminada correctamente');
      if (context.canPop()) context.pop(true);
    } catch (_) {
      if (!mounted) return;
      _showInfo('No se pudo eliminar la sesion.', error: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _onFinalize() async {
    if (_isFinalizing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Finalizar sesion',
        description:
            'Los estudiantes sin registro se marcaran como falta. Esta accion no se puede deshacer.',
        confirmText: 'Finalizar',
      ),
    );
    if (confirmed != true) return;

    setState(() => _isFinalizing = true);
    try {
      final summary = await ref
          .read(attendanceRepositoryProvider)
          .finalizeSession(widget.schoolId, widget.sessionId);
      if (!mounted) return;
      _showInfo(
        'Sesion finalizada. Faltantes marcados como falta: ${summary.createdMissing}',
      );
      await ref
          .read(attendanceSessionDetailProvider.notifier)
          .load(widget.schoolId, widget.sessionId, forceRefresh: true);
    } catch (_) {
      if (!mounted) return;
      _showInfo('No se pudo finalizar la sesion de asistencia.', error: true);
    } finally {
      if (mounted) setState(() => _isFinalizing = false);
    }
  }

  Future<void> _onMarkStudent(
    String studentId,
    AttendanceStatusOption status,
  ) async {
    final ok = await ref
        .read(attendanceSessionDetailProvider.notifier)
        .markStudentStatus(studentId, status.id);
    if (!ok && mounted) {
      _showInfo('No se pudo registrar la asistencia.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceSessionDetailProvider);
    final session = state.session;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
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
                        'Asistir',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF0F2C4F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (session != null)
                      AppCircleIconButton(
                        onPressed: _isDeleting
                            ? () {}
                            : () => _onDelete(session),
                        icon: Icons.delete_outline_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (session == null)
                  const Expanded(
                    child: Center(child: Text('No se encontro la sesion.')),
                  )
                else
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        AttendanceSessionInfoCard(
                          session: session,
                          isFinalizing: _isFinalizing,
                          onFinalize: _onFinalize,
                        ),
                        const SizedBox(height: 12),
                        AttendanceStudentsListCard(
                          rows: state.rows,
                          statusOptions: state.statusOptions,
                          pendingKey: state.pendingKey,
                          disabled: session.isClosed,
                          onMark: _onMarkStudent,
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
