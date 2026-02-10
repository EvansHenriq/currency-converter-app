import 'package:flutter/material.dart';

class CurrencyInputField extends StatelessWidget {
  final String label;
  final String prefix;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const CurrencyInputField({
    super.key,
    required this.label,
    required this.prefix,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
      ),
      style: theme.textTheme.titleLarge,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
