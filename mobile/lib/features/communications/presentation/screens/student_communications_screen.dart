import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/providers.dart';
import 'package:mobile/features/communications/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentCommunicationsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String courseId;
  final String studentId;
  final String? courseName;
  final String? studentName;

  const StudentCommunicationsScreen({
    super.key,
    required this.schoolId,
    required this.courseId,
    required this.studentId,
    this.courseName,
    this.studentName,
  });

  @override
  ConsumerState<StudentCommunicationsScreen> createState() => _StudentCommunicationsScreenState();
}

class _StudentCommunicationsScreenState extends ConsumerState<StudentCommunicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentCommunicationsProvider.notifier).load(widget.schoolId, widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentCommunicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: RegisterStudentCommunicationFabButton(
        schoolId: widget.schoolId,
        studentId: widget.studentId,
        onCreated: () {
          ref
              .read(studentCommunicationsProvider.notifier)
              .load(widget.schoolId, widget.studentId, forceRefresh: true);
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
                    AppCircleIconButton(onPressed: context.pop, icon: Icons.arrow_back_ios_new_rounded),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.studentName?.trim().isNotEmpty == true ? widget.studentName! : 'Comunicados',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF0F2C4F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if ((widget.courseName ?? '').trim().isNotEmpty)
                  Text(
                    'Curso: ${widget.courseName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF35597E)),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _SummaryCard(total: state.communications.length),
                            const SizedBox(height: 12),
                            _CommunicationsListCard(
                              state: state,
                              onEdited: () => ref
                                  .read(studentCommunicationsProvider.notifier)
                                  .load(
                                    widget.schoolId,
                                    widget.studentId,
                                    forceRefresh: true,
                                  ),
                              onDeleted: () => ref
                                  .read(studentCommunicationsProvider.notifier)
                                  .load(
                                    widget.schoolId,
                                    widget.studentId,
                                    forceRefresh: true,
                                  ),
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

class _SummaryCard extends StatelessWidget {
  final int total;

  const _SummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1E4A75).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.summarize_outlined, color: Color(0xFF1E4A75)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Publicaciones registradas: $total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1E3A5F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunicationsListCard extends StatelessWidget {
  final StudentCommunicationsState state;
  final VoidCallback onEdited;
  final VoidCallback onDeleted;

  const _CommunicationsListCard({
    required this.state,
    required this.onEdited,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: state.communications.isEmpty
          ? Text(
              'Aun no hay comunicados para este estudiante.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
            )
          : Column(
              children: state.communications
                  .map(
                    (item) => _CommunicationItemCard(
                      item: item,
                      onEdited: onEdited,
                      onDeleted: onDeleted,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _CommunicationItemCard extends ConsumerStatefulWidget {
  final StudentCommunication item;
  final VoidCallback onEdited;
  final VoidCallback onDeleted;

  const _CommunicationItemCard({
    required this.item,
    required this.onEdited,
    required this.onDeleted,
  });

  @override
  ConsumerState<_CommunicationItemCard> createState() =>
      _CommunicationItemCardState();
}

class _CommunicationItemCardState extends ConsumerState<_CommunicationItemCard> {
  bool _isSubmitting = false;

  Future<void> _onEdit() async {
    if (_isSubmitting) return;

    final payload = await showStudentCommunicationUpsertSheet(
      context,
      title: 'Editar comunicado',
      description: 'Actualiza el titulo y la descripcion del comunicado.',
      confirmText: 'Guardar cambios',
      initialTitle: widget.item.title,
      initialBody: widget.item.body,
    );

    if (payload == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(communicationRepositoryProvider).updateStudentCommunication(
        widget.item.schoolId,
        widget.item.id,
        payload.title,
        payload.body,
      );

      if (!mounted) return;
      widget.onEdited();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comunicado actualizado correctamente.'),
          backgroundColor: Color.fromARGB(255, 31, 110, 69),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo actualizar el comunicado.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onDelete() async {
    if (_isSubmitting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Eliminar comunicado',
        description: 'Esta accion no se puede deshacer.',
        confirmText: 'Eliminar',
        cancelText: 'Cancelar',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(communicationRepositoryProvider).deleteStudentCommunication(
        widget.item.schoolId,
        widget.item.id,
      );

      if (!mounted) return;
      widget.onDeleted();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comunicado eliminado correctamente.'),
          backgroundColor: Color.fromARGB(255, 31, 110, 69),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo eliminar el comunicado.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5E3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF1F4D7D),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(widget.item.createdDate),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6A8CB2),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(widget.item.body, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomFilledButton(
                  text: 'Editar',
                  onPressed: _isSubmitting ? null : _onEdit,
                  buttonColor: const Color(0xFFE4EBF4),
                  textColor: const Color(0xFF1F476E),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomFilledButton(
                  text: _isSubmitting ? 'Procesando...' : 'Eliminar',
                  onPressed: _isSubmitting ? null : _onDelete,
                  buttonColor: const Color(0xFFF8E2E2),
                  textColor: const Color(0xFF9F2D2D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Sin fecha';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}
