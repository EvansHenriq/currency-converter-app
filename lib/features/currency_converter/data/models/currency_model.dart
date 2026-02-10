import '../../domain/entities/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({
    required super.code,
    required super.name,
    required super.buyRate,
    required super.sellRate,
    required super.variation,
  });

  factory CurrencyModel.fromJson(String code, Map<String, dynamic> json) {
    return CurrencyModel(
      code: code,
      name: json['name'] as String? ?? code,
      buyRate: (json['buy'] as num?)?.toDouble() ?? 0.0,
      sellRate: (json['sell'] as num?)?.toDouble() ?? 0.0,
      variation: (json['variation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'buy': buyRate,
      'sell': sellRate,
      'variation': variation,
    };
  }
}

class ExchangeRatesModel extends ExchangeRates {
  const ExchangeRatesModel({
    required super.currencies,
    required super.updatedAt,
  });

  factory ExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>;
    final currenciesJson = results['currencies'] as Map<String, dynamic>;

    final Map<String, Currency> parsed = {};
    for (final entry in currenciesJson.entries) {
      if (entry.key == 'source') continue;
      if (entry.value is Map<String, dynamic>) {
        parsed[entry.key] = CurrencyModel.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }
    }

    return ExchangeRatesModel(
      currencies: parsed,
      updatedAt: DateTime.now(),
    );
  }
}
