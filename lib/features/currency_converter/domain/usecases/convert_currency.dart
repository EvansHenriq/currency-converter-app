import 'package:equatable/equatable.dart';

class ConvertCurrency {
  ConversionResult call(ConvertCurrencyParams params) {
    final double amountInBrl = params.amount * params.fromRate;

    final Map<String, double> converted = {};
    for (final entry in params.rates.entries) {
      converted[entry.key] = amountInBrl / entry.value;
    }

    return ConversionResult(values: converted);
  }
}

class ConvertCurrencyParams extends Equatable {
  final double amount;
  final String fromCurrency;
  final double fromRate;
  final Map<String, double> rates;

  const ConvertCurrencyParams({
    required this.amount,
    required this.fromCurrency,
    required this.fromRate,
    required this.rates,
  });

  @override
  List<Object?> get props => [amount, fromCurrency, fromRate, rates];
}

class ConversionResult extends Equatable {
  final Map<String, double> values;

  const ConversionResult({required this.values});

  double operator [](String code) => values[code] ?? 0.0;

  @override
  List<Object?> get props => [values];
}
