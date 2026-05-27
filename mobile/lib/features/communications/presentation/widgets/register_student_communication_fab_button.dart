import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/communications/presentation/providers/providers.dart';
import 'package:mobile/features/communications/presentation/widgets/student_communication_upsert_sheet.dart';
import 'package:mobile/features/shared/shared.dart';

class RegisterStudentCommunicationFabButton extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final VoidCallback onCreated;

  const RegisterStudentCommunicationFabButton({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.onCreated,
  });

  @override
  ConsumerState<RegisterStudentCommunicationFabButton> createState() =>
      _RegisterStudentCommunicationFabButtonState();
}

class _RegisterStudentCommunicationFabButtonState
    extends ConsumerState<RegisterStudentCommunicationFabButton> {
  bool _isPosting = false;

  Future<void> _onTap() async {
    if (_isPosting) return;

    final payload = await showStudentCommunicationUpsertSheet(
      context,
      title: 'Registrar comunicado',
      description: 'Completa los datos para crear un nuevo comunicado.',
      confirmText: 'Registrar comunicado',
    );

    if (payload == null) return;

    setState(() => _isPosting = true);
    try {
      await ref
          .read(communicationRepositoryProvider)
          .createStudentCommunication(
            widget.schoolId,
            widget.studentId,
            payload.title,
            payload.body,
          );

      if (!mounted) return;
      widget.onCreated();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comunicado registrado correctamente.'),
          backgroundColor: Color.fromARGB(255, 31, 110, 69),
        ),
      );
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo registrar el comunicado.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo registrar el comunicado.'),
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
      text: _isPosting ? 'Registrando...' : 'Registrar comunicado',
      icon: Icons.add,
    );
  }
}
