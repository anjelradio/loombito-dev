import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/evaluations/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

class EvaluationFormFields extends ConsumerWidget {
  final EvaluationFormConfig config;

  const EvaluationFormFields({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(evaluationFormProvider(config));
    final formNotifier = ref.read(evaluationFormProvider(config).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          label: 'Titulo',
          hint: 'Ej: Examen parcial',
          initialValue: formState.name.value,
          onChanged: formNotifier.onNameChanged,
          errorMessage: formState.isFormPosted
              ? formState.name.errorMessage
              : null,
        ),
        const SizedBox(height: 12),
        CustomTextFormField(
          label: 'Descripcion (opcional)',
          hint: 'Ej: Evaluacion del tema 3',
          initialValue: formState.description.value,
          onChanged: formNotifier.onDescriptionChanged,
          errorMessage: formState.isFormPosted
              ? formState.description.errorMessage
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          'Tipo de evaluacion',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _ChipsSelector(
          selectedId: formState.evaluationTypeId.value,
          options: config.typeOptions
              .map(
                (item) =>
                    SelectableChipOption(value: item.id, label: item.name),
              )
              .toList(),
          onSelected: formNotifier.onTypeChanged,
        ),
        if (formState.isFormPosted &&
            formState.evaluationTypeId.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              formState.evaluationTypeId.errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFEF4444)),
            ),
          ),
        const SizedBox(height: 12),
        _DateSelectorField(
          value: formState.presentationDate.value,
          errorText: formState.isFormPosted
              ? formState.presentationDate.errorMessage
              : null,
          onDateSelected: formNotifier.onPresentationDateChanged,
        ),
        const SizedBox(height: 12),
        Text(
          'Trimestre',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _ChipsSelector(
          selectedId: formState.termId.value,
          options: config.termOptions
              .map(
                (item) =>
                    SelectableChipOption(value: item.id, label: item.name),
              )
              .toList(),
          onSelected: formNotifier.onTermChanged,
        ),
        if (formState.isFormPosted && formState.termId.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              formState.termId.errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFEF4444)),
            ),
          ),
      ],
    );
  }
}

class _DateSelectorField extends StatelessWidget {
  final String value;
  final String? errorText;
  final void Function(String) onDateSelected;

  const _DateSelectorField({
    required this.value,
    required this.errorText,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText == null
        ? const Color(0xFFE5E7EB)
        : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final initialDate = _tryParse(value) ?? DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked == null) return;
            final normalized =
                '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            onDateSelected(normalized);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Fecha de presentacion' : value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFEF4444)),
            ),
          ),
      ],
    );
  }

  DateTime? _tryParse(String raw) {
    if (raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

class _ChipsSelector extends StatelessWidget {
  final String selectedId;
  final List<SelectableChipOption> options;
  final void Function(String) onSelected;

  const _ChipsSelector({
    required this.selectedId,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableChips(
      options: options,
      selectedValues: selectedId.isEmpty ? const [] : [selectedId],
      onChange: (values) => onSelected(values.isNotEmpty ? values.first : ''),
    );
  }
}
