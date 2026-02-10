import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code;
  final String name;
  final double buyRate;
  final double sellRate;
  final double variation;

  const Currency({
    required this.code,
    required this.name,
    required this.buyRate,
    required this.sellRate,
    required this.variation,
  });

  @override
  List<Object?> get props => [code, name, buyRate, sellRate, variation];
}

class ExchangeRates extends Equatable {
  final Map<String, Currency> currencies;
  final DateTime updatedAt;

  const ExchangeRates({
    required this.currencies,
    required this.updatedAt,
  });

  Currency? operator [](String code) => currencies[code];

  List<String> get availableCodes => currencies.keys.toList();

  double rateFor(String code) {
    if (code == 'BRL') return 1.0;
    return currencies[code]?.buyRate ?? 1.0;
  }

  @override
  List<Object?> get props => [currencies, updatedAt];
}
