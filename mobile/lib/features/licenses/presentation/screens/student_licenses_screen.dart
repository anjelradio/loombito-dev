import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/licenses/domain/domain.dart';
import 'package:mobile/features/licenses/presentation/providers/providers.dart';
import 'package:mobile/features/licenses/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentLicensesScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final String? studentName;

  const StudentLicensesScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    this.studentName,
  });

  @override
  ConsumerState<StudentLicensesScreen> createState() => _StudentLicensesScreenState();
}

class _StudentLicensesScreenState extends ConsumerState<StudentLicensesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentLicensesProvider.notifier).load(widget.schoolId, widget.studentId);
    });
  }

  void _refresh() {
    ref.read(studentLicensesProvider.notifier).load(
          widget.schoolId,
          widget.studentId,
          forceRefresh: true,
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

  Future<void> _editLicense(StudentLicense license) async {
    final payload = await showRegisterLicenseSheetWithInitial(
      context,
      initialPayload: RegisterLicensePayload(
        licenseId: license.id,
        reason: license.reason,
        description: license.description,
        startDate: license.startDate,
        endDate: license.endDate,
      ),
      title: 'Editar licencia',
      submitText: 'Actualizar',
    );
    if (payload == null) return;
    if (payload.licenseId == null) return;

    try {
      await ref.read(licenseRepositoryProvider).updateStudentLicense(
            widget.schoolId,
            widget.studentId,
            payload.licenseId!,
            payload.reason,
            payload.description,
            payload.startDate,
            payload.endDate,
          );
      if (!mounted) return;
      _refresh();
      _showInfo('Licencia actualizada correctamente.');
    } on DioException catch (error) {
      if (!mounted) return;
      String message = 'No se pudo actualizar la licencia.';
      final detail = error.response?.data;
      if (detail is Map<String, dynamic> && detail['detail'] is String) {
        message = detail['detail'] as String;
      }
      _showInfo(message, error: true);
    } catch (_) {
      if (!mounted) return;
      _showInfo('No se pudo actualizar la licencia.', error: true);
    }
  }

  Future<void> _deleteLicense(StudentLicense license) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AppConfirmDialog(
        title: 'Eliminar licencia',
        description: '¿Estas seguro de que quieres eliminar esta licencia?',
        confirmText: 'Eliminar',
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(licenseRepositoryProvider).deleteStudentLicense(
            widget.schoolId,
            widget.studentId,
            license.id,
          );
      if (!mounted) return;
      _refresh();
      _showInfo('Licencia eliminada correctamente.');
    } on DioException catch (error) {
      if (!mounted) return;
      String message = 'No se pudo eliminar la licencia.';
      final detail = error.response?.data;
      if (detail is Map<String, dynamic> && detail['detail'] is String) {
        message = detail['detail'] as String;
      }
      _showInfo(message, error: true);
    } catch (_) {
      if (!mounted) return;
      _showInfo('No se pudo eliminar la licencia.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentLicensesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: RegisterLicenseFabButton(
        schoolId: widget.schoolId,
        studentId: widget.studentId,
        onCreated: _refresh,
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
                        'Licencias',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF0F2C4F),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if ((widget.studentName ?? '').trim().isNotEmpty)
                  Text(
                    widget.studentName!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF35597E),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFD8E5F2)),
                              ),
                              child: Text(
                                'Licencias registradas: ${state.licenses.length}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF1E3A5F),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (state.licenses.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFD8E5F2)),
                                ),
                                child: Text(
                                  'Aun no hay licencias registradas para este estudiante.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF4B5563),
                                      ),
                                ),
                              )
                            else
                              ...state.licenses.map(
                                (item) => _LicenseCard(
                                  license: item,
                                  reasonLabel: _reasonLabel(item.reason),
                                  onEdit: () => _editLicense(item),
                                  onDelete: () => _deleteLicense(item),
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

  String _reasonLabel(String reason) {
    switch (reason) {
      case 'illness':
        return 'Enfermedad';
      case 'travel':
        return 'Viaje';
      case 'personal':
        return 'Personal';
      default:
        return reason;
    }
  }
}

class _LicenseCard extends StatelessWidget {
  final StudentLicense license;
  final String reasonLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LicenseCard({
    required this.license,
    required this.reasonLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD5E3F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reasonLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF1F4D7D),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${license.startDate} - ${license.endDate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6A8CB2),
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CardIconButton(
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF1F476E),
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 4),
                    _CardIconButton(
                      icon: Icons.delete_rounded,
                      color: const Color(0xFF9C2F2F),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(license.description, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CardIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
