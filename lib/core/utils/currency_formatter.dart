class CurrencyFormatConfig {
  final String decimalSeparator;
  final String thousandsSeparator;
  final int decimalPlaces;

  const CurrencyFormatConfig({
    required this.decimalSeparator,
    required this.thousandsSeparator,
    required this.decimalPlaces,
  });
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, CurrencyFormatConfig> _configs = {
    'BRL': CurrencyFormatConfig(decimalSeparator: ',', thousandsSeparator: '.', decimalPlaces: 2),
    'USD': CurrencyFormatConfig(decimalSeparator: '.', thousandsSeparator: ',', decimalPlaces: 2),
    'EUR': CurrencyFormatConfig(decimalSeparator: ',', thousandsSeparator: '.', decimalPlaces: 2),
    'GBP': CurrencyFormatConfig(decimalSeparator: '.', thousandsSeparator: ',', decimalPlaces: 2),
    'ARS': CurrencyFormatConfig(decimalSeparator: ',', thousandsSeparator: '.', decimalPlaces: 2),
    'CAD': CurrencyFormatConfig(decimalSeparator: '.', thousandsSeparator: ',', decimalPlaces: 2),
    'AUD': CurrencyFormatConfig(decimalSeparator: '.', thousandsSeparator: ',', decimalPlaces: 2),
    'JPY': CurrencyFormatConfig(decimalSeparator: '', thousandsSeparator: ',', decimalPlaces: 0),
    'CNY': CurrencyFormatConfig(decimalSeparator: '.', thousandsSeparator: ',', decimalPlaces: 2),
    'BTC': CurrencyFormatConfig(decimalSeparator: '.', thousandsSeparator: ',', decimalPlaces: 8),
  };

  static CurrencyFormatConfig configFor(String currencyCode) {
    return _configs[currencyCode] ??
        const CurrencyFormatConfig(
          decimalSeparator: '.',
          thousandsSeparator: ',',
          decimalPlaces: 2,
        );
  }

  static String formatValue(double value, String currencyCode) {
    final config = configFor(currencyCode);
    final String fixed = value.toStringAsFixed(config.decimalPlaces);
    final parts = fixed.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final formattedInteger = addThousandsSeparator(
      integerPart,
      config.thousandsSeparator,
    );

    if (config.decimalPlaces == 0) {
      return formattedInteger;
    }
    return '$formattedInteger${config.decimalSeparator}$decimalPart';
  }

  static double? parseValue(String text, String currencyCode) {
    if (text.isEmpty) return null;

    final config = configFor(currencyCode);

    String cleaned = text;
    if (config.thousandsSeparator.isNotEmpty) {
      cleaned = cleaned.replaceAll(config.thousandsSeparator, '');
    }

    if (config.decimalSeparator == ',') {
      cleaned = cleaned.replaceAll(',', '.');
    }

    return double.tryParse(cleaned);
  }

  static String addThousandsSeparator(String integerPart, String separator) {
    if (separator.isEmpty || integerPart.length <= 3) {
      return integerPart;
    }

    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    if (digits.length <= 3) return integerPart;

    final buffer = StringBuffer();
    final remainder = digits.length % 3;

    if (remainder > 0) {
      buffer.write(digits.substring(0, remainder));
      if (digits.length > remainder) {
        buffer.write(separator);
      }
    }

    for (int i = remainder; i < digits.length; i += 3) {
      if (i > remainder) buffer.write(separator);
      buffer.write(digits.substring(i, i + 3));
    }

    return isNegative ? '-${buffer.toString()}' : buffer.toString();
  }
}
