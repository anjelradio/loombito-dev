import 'dart:io';

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
  final String? licenseId;
  final String reason;
  final String description;
  final String startDate;
  final String endDate;
  final String? attachmentImagePath;

  RegisterLicensePayload({
    this.licenseId,
    required this.reason,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.attachmentImagePath,
  });
}

Future<RegisterLicensePayload?> showRegisterLicenseSheet(BuildContext context) {
  return showRegisterLicenseSheetWithInitial(context);
}

Future<RegisterLicensePayload?> showRegisterLicenseSheetWithInitial(
  BuildContext context, {
  RegisterLicensePayload? initialPayload,
  String title = 'Registrar licencia',
  String submitText = 'Registrar licencia',
}) {
  return showModalBottomSheet<RegisterLicensePayload>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RegisterLicenseSheetContent(
      initialPayload: initialPayload,
      title: title,
      submitText: submitText,
    ),
  );
}

class _RegisterLicenseSheetContent extends StatefulWidget {
  final RegisterLicensePayload? initialPayload;
  final String title;
  final String submitText;

  const _RegisterLicenseSheetContent({
    this.initialPayload,
    required this.title,
    required this.submitText,
  });

  @override
  State<_RegisterLicenseSheetContent> createState() => _RegisterLicenseSheetContentState();
}

class _RegisterLicenseSheetContentState extends State<_RegisterLicenseSheetContent> {
  final TextEditingController _descriptionController = TextEditingController();
  final CameraGalleryService _cameraGalleryService = CameraGalleryServiceImpl();
  String _reason = 'illness';
  String _startDate = '';
  String _endDate = '';
  String? _licenseId;
  String? _attachmentImagePath;
  String? _descriptionError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPayload;
    if (initial == null) return;
    _licenseId = initial.licenseId;
    _reason = initial.reason;
    _startDate = initial.startDate;
    _endDate = initial.endDate;
    _attachmentImagePath = initial.attachmentImagePath;
    _descriptionController.text = initial.description;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachmentImage() async {
    final imagePath = await _cameraGalleryService.selectPhoto();
    if (!mounted || imagePath == null) return;
    setState(() => _attachmentImagePath = imagePath);
  }

  void _removeAttachmentImage() {
    setState(() => _attachmentImagePath = null);
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
        licenseId: _licenseId,
        reason: _reason,
        description: description,
        startDate: _startDate,
        endDate: _endDate,
        attachmentImagePath: _attachmentImagePath,
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
                  widget.title,
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
                  initialValue: _descriptionController.text,
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
                const SizedBox(height: 12),
                _AttachmentImageCard(
                  imagePath: _attachmentImagePath,
                  onPickImage: _pickAttachmentImage,
                  onRemoveImage: _removeAttachmentImage,
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
                        text: widget.submitText,
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

class _AttachmentImageCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _AttachmentImageCard({
    required this.imagePath,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (imagePath ?? '').isNotEmpty;
    final fileName = hasImage ? imagePath!.split('/').last : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjuntar imagen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E3A5F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasImage ? 'Imagen seleccionada.' : 'Agrega una imagen de respaldo para la licencia.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4B5563),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagePath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6A8CB2),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomFilledButton(
                  text: hasImage ? 'Cambiar imagen' : 'Adjuntar imagen',
                  buttonColor: const Color(0xFFE4EBF4),
                  textColor: const Color(0xFF1F476E),
                  onPressed: onPickImage,
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: CustomFilledButton(
                    text: 'Quitar',
                    buttonColor: const Color(0xFFFDECEC),
                    textColor: const Color(0xFF9F2F2F),
                    onPressed: onRemoveImage,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
