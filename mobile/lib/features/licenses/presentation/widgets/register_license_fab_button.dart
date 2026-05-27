import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/licenses/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

class RegisterLicenseFabButton extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final VoidCallback onCreated;

  const RegisterLicenseFabButton({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.onCreated,
  });

  @override
  ConsumerState<RegisterLicenseFabButton> createState() => _RegisterLicenseFabButtonState();
}

class _RegisterLicenseFabButtonState extends ConsumerState<RegisterLicenseFabButton> {
  bool _isPosting = false;

  Future<void> _openSheet() async {
    if (_isPosting) return;
    final payload = await showRegisterLicenseSheet(context);
    if (payload == null) return;

    setState(() => _isPosting = true);
    try {
      await ref
          .read(licenseRepositoryProvider)
          .createStudentLicense(
            widget.schoolId,
            widget.studentId,
            payload.reason,
            payload.description,
            payload.startDate,
            payload.endDate,
          );
      if (!mounted) return;
      widget.onCreated();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Licencia registrada correctamente.'),
          backgroundColor: Color.fromARGB(255, 31, 110, 69),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      String message = 'No se pudo registrar la licencia.';
      final detail = error.response?.data;
      if (detail is Map<String, dynamic> && detail['detail'] is String) {
        message = detail['detail'] as String;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo registrar la licencia.'),
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
      onTap: _openSheet,
      text: _isPosting ? 'Registrando...' : 'Registrar licencia',
      icon: Icons.add,
    );
  }
}

class RegisterLicensePayload {
  final String reason;
  final String description;
  final String startDate;
  final String endDate;

  RegisterLicensePayload({
    required this.reason,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}

Future<RegisterLicensePayload?> showRegisterLicenseSheet(BuildContext context) {
  return showModalBottomSheet<RegisterLicensePayload>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RegisterLicenseSheetContent(),
  );
}

class _RegisterLicenseSheetContent extends StatefulWidget {
  const _RegisterLicenseSheetContent();

  @override
  State<_RegisterLicenseSheetContent> createState() => _RegisterLicenseSheetContentState();
}

class _RegisterLicenseSheetContentState extends State<_RegisterLicenseSheetContent> {
  final TextEditingController _descriptionController = TextEditingController();
  String _reason = 'illness';
  String _startDate = '';
  String _endDate = '';
  String? _descriptionError;
  String? _dateError;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    final normalized =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      if (start) {
        _startDate = normalized;
      } else {
        _endDate = normalized;
      }
    });
  }

  void _submit() {
    final description = _descriptionController.text.trim();
    setState(() {
      _descriptionError = description.isEmpty ? 'Debes ingresar una descripcion' : null;
      _dateError = _startDate.isEmpty || _endDate.isEmpty
          ? 'Debes seleccionar fecha de inicio y fecha de fin'
          : null;
    });

    if (_descriptionError != null || _dateError != null) return;

    Navigator.of(context).pop(
      RegisterLicensePayload(
        reason: _reason,
        description: description,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar licencia',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF0F2C4F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona motivo, descripcion y rango de fechas.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
                ),
                const SizedBox(height: 14),
                Text(
                  'Motivo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1E3A5F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableChips(
                  options: const [
                    SelectableChipOption(value: 'illness', label: 'Enfermedad'),
                    SelectableChipOption(value: 'travel', label: 'Viaje'),
                    SelectableChipOption(value: 'personal', label: 'Personal'),
                  ],
                  selectedValues: [_reason],
                  onChange: (values) {
                    if (values.isNotEmpty) {
                      setState(() => _reason = values.first);
                    }
                  },
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  label: 'Descripcion',
                  hint: 'Describe el motivo de la licencia.',
                  initialValue: '',
                  onChanged: (value) => _descriptionController.text = value,
                  errorMessage: _descriptionError,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomFilledButton(
                        text: _startDate.isEmpty ? 'Fecha inicio' : _startDate,
                        buttonColor: const Color(0xFFE4EBF4),
                        textColor: const Color(0xFF1F476E),
                        onPressed: () => _pickDate(start: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomFilledButton(
                        text: _endDate.isEmpty ? 'Fecha fin' : _endDate,
                        buttonColor: const Color(0xFFE4EBF4),
                        textColor: const Color(0xFF1F476E),
                        onPressed: () => _pickDate(start: false),
                      ),
                    ),
                  ],
                ),
                if (_dateError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _dateError!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFEF4444)),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomFilledButton(
                        text: 'Cancelar',
                        buttonColor: const Color(0xFFE4EBF4),
                        textColor: const Color(0xFF1F476E),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomFilledButton(
                        text: 'Registrar licencia',
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
