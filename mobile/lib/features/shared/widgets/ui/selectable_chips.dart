import 'package:flutter/material.dart';

class SelectableChipOption {
  final String value;
  final String label;

  const SelectableChipOption({required this.value, required this.label});
}

class SelectableChips extends StatelessWidget {
  final List<SelectableChipOption> options;
  final List<String> selectedValues;
  final void Function(List<String> values)? onChange;
  final bool multiple;
  final bool readOnly;

  const SelectableChips({
    super.key,
    required this.options,
    required this.selectedValues,
    this.onChange,
    this.multiple = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedSet = selectedValues.toSet();
    const primaryBlue = Color(0xFF1F476E);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedSet.contains(option.value);

        return InkWell(
          onTap: () {
            if (readOnly || onChange == null) return;

            if (multiple) {
              if (isSelected) {
                onChange!(
                  selectedValues
                      .where((selected) => selected != option.value)
                      .toList(),
                );
              } else {
                onChange!([...selectedValues, option.value]);
              }
              return;
            }

            onChange!([option.value]);
          },
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? primaryBlue : const Color(0xFFCBD5E1),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
