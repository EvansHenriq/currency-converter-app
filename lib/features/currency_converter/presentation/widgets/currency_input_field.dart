import 'package:flutter/material.dart';

import '../../../../core/utils/currency_input_formatter.dart';

class CurrencyMetadata {
  CurrencyMetadata._();

  static const Map<String, String> _flags = {
    'BRL': '\u{1F1E7}\u{1F1F7}',
    'USD': '\u{1F1FA}\u{1F1F8}',
    'EUR': '\u{1F1EA}\u{1F1FA}',
    'GBP': '\u{1F1EC}\u{1F1E7}',
    'ARS': '\u{1F1E6}\u{1F1F7}',
    'CAD': '\u{1F1E8}\u{1F1E6}',
    'AUD': '\u{1F1E6}\u{1F1FA}',
    'JPY': '\u{1F1EF}\u{1F1F5}',
    'CNY': '\u{1F1E8}\u{1F1F3}',
    'BTC': '\u{1FA99}',
  };

  static const Map<String, String> _prefixes = {
    'BRL': 'R\$ ',
    'USD': 'US\$ ',
    'EUR': '\u20AC ',
    'GBP': '\u00A3 ',
    'ARS': 'ARS ',
    'CAD': 'CA\$ ',
    'AUD': 'AU\$ ',
    'JPY': '\u00A5 ',
    'CNY': '\u00A5 ',
    'BTC': '\u20BF ',
  };

  static const Map<String, String> _labels = {
    'BRL': 'Real',
    'USD': 'Dolar',
    'EUR': 'Euro',
    'GBP': 'Libra',
    'ARS': 'Peso Argentino',
    'CAD': 'Dolar Canadense',
    'AUD': 'Dolar Australiano',
    'JPY': 'Iene',
    'CNY': 'Renminbi',
    'BTC': 'Bitcoin',
  };

  static String flagFor(String code) => _flags[code] ?? '\u{1F4B1}';
  static String prefixFor(String code) => _prefixes[code] ?? '$code ';
  static String labelFor(String code) => _labels[code] ?? code;
}

class CurrencyInputField extends StatelessWidget {
  final String label;
  final String prefix;
  final String currencyCode;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const CurrencyInputField({
    super.key,
    required this.label,
    required this.prefix,
    required this.controller,
    this.currencyCode = '',
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (currencyCode.isNotEmpty) ...[
          SizedBox(
            width: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyMetadata.flagFor(currencyCode),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyCode,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: label,
              prefixText: prefix,
            ),
            style: theme.textTheme.titleLarge,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [
              CurrencyTextInputFormatter(currencyCode: currencyCode),
            ],
          ),
        ),
      ],
    );
  }
}
