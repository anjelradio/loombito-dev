import 'package:flutter/material.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentCommunicationUpsertResult {
  final String title;
  final String body;

  StudentCommunicationUpsertResult({required this.title, required this.body});
}

Future<StudentCommunicationUpsertResult?> showStudentCommunicationUpsertSheet(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmText,
  String initialTitle = '',
  String initialBody = '',
}) {
  return showModalBottomSheet<StudentCommunicationUpsertResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _StudentCommunicationUpsertSheetContent(
        title: title,
        description: description,
        confirmText: confirmText,
        initialTitle: initialTitle,
        initialBody: initialBody,
      );
    },
  );
}

class _StudentCommunicationUpsertSheetContent extends StatefulWidget {
  final String title;
  final String description;
  final String confirmText;
  final String initialTitle;
  final String initialBody;

  const _StudentCommunicationUpsertSheetContent({
    required this.title,
    required this.description,
    required this.confirmText,
    required this.initialTitle,
    required this.initialBody,
  });

  @override
  State<_StudentCommunicationUpsertSheetContent> createState() =>
      _StudentCommunicationUpsertSheetContentState();
}

class _StudentCommunicationUpsertSheetContentState
    extends State<_StudentCommunicationUpsertSheetContent> {
  late final TextEditingController _bodyController;
  late String _titleValue;
  String? _titleError;
  String? _bodyError;

  @override
  void initState() {
    super.initState();
    _titleValue = widget.initialTitle;
    _bodyController = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    final normalizedTitle = _titleValue.trim();
    final normalizedBody = _bodyController.text.trim();

    setState(() {
      _titleError = normalizedTitle.isEmpty ? 'Debes ingresar un titulo' : null;
      _bodyError = normalizedBody.isEmpty ? 'Debes ingresar una descripcion' : null;
    });

    if (_titleError != null || _bodyError != null) return;

    Navigator.of(context).pop(
      StudentCommunicationUpsertResult(
        title: normalizedTitle,
        body: normalizedBody,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.79,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
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
                  widget.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
                ),
                const SizedBox(height: 14),
                CustomTextFormField(
                  label: 'Titulo',
                  hint: 'Ej: Recordatorio de tareas',
                  initialValue: widget.initialTitle,
                  onChanged: (value) => _titleValue = value,
                  errorMessage: _titleError,
                ),
                const SizedBox(height: 12),
                Text(
                  'Descripcion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1E3A5F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Describe el comunicado para la familia.',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _bodyError == null
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _bodyError == null
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
                if (_bodyError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _bodyError!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: const Color(0xFFEF4444)),
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
                        text: widget.confirmText,
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
