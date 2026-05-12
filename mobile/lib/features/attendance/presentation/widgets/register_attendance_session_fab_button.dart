import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/attendance/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

class RegisterAttendanceSessionFabButton extends ConsumerStatefulWidget {
  final String schoolId;
  final String assignmentId;
  final VoidCallback onCreated;

  const RegisterAttendanceSessionFabButton({
    super.key,
    required this.schoolId,
    required this.assignmentId,
    required this.onCreated,
  });

  @override
  ConsumerState<RegisterAttendanceSessionFabButton> createState() =>
      _RegisterAttendanceSessionFabButtonState();
}

class _RegisterAttendanceSessionFabButtonState
    extends ConsumerState<RegisterAttendanceSessionFabButton> {
  bool _isPosting = false;

  Future<void> _onTap() async {
    if (_isPosting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Registrar asistencia',
        description: '¿Estas seguro de que quieres crear una asistencia?',
        confirmText: 'Crear',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPosting = true);
    try {
      final today = DateTime.now();
      final todayIso =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final session = await ref
          .read(attendanceRepositoryProvider)
          .createAttendanceSession(
            widget.schoolId,
            todayIso,
            widget.assignmentId,
          );

      if (!mounted) return;

      if (session.id.trim().isEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'La sesion se creo, pero no se pudo resolver el destino.',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
        return;
      }

      widget.onCreated();
      context.push('/schools/${widget.schoolId}/teacher/asistir/${session.id}');
    } on DioException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo crear la sesion de asistencia.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo crear la sesion de asistencia.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalPageFabButton(
      onTap: _onTap,
      text: _isPosting ? 'Creando...' : 'Registrar asistencia',
      icon: Icons.add,
    );
  }
}
