import 'package:flutter/services.dart';

import 'currency_formatter.dart';

class CurrencyTextInputFormatter extends TextInputFormatter {
  final String currencyCode;

  CurrencyTextInputFormatter({required this.currencyCode});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    final config = CurrencyFormatter.configFor(currencyCode);
    final formatted = _formatDigits(digits, config);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatDigits(String digits, CurrencyFormatConfig config) {
    final decimalPlaces = config.decimalPlaces;

    if (decimalPlaces == 0) {
      final cleaned = digits.replaceFirst(RegExp(r'^0+'), '');
      final value = cleaned.isEmpty ? '0' : cleaned;
      return CurrencyFormatter.addThousandsSeparator(
        value,
        config.thousandsSeparator,
      );
    }

    var padded = digits;
    while (padded.length <= decimalPlaces) {
      padded = '0$padded';
    }

    final integerPart = padded.substring(0, padded.length - decimalPlaces);
    final decimalPart = padded.substring(padded.length - decimalPlaces);

    var cleanInteger = integerPart.replaceFirst(RegExp(r'^0+'), '');
    if (cleanInteger.isEmpty) {
      cleanInteger = '0';
    }

    final formattedInteger = CurrencyFormatter.addThousandsSeparator(
      cleanInteger,
      config.thousandsSeparator,
    );

    return '$formattedInteger${config.decimalSeparator}$decimalPart';
  }
}
