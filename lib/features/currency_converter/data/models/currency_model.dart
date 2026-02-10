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
    required super.usd,
    required super.eur,
    required super.updatedAt,
  });

  factory ExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>;
    final currencies = results['currencies'] as Map<String, dynamic>;

    return ExchangeRatesModel(
      usd: CurrencyModel.fromJson(
        'USD',
        currencies['USD'] as Map<String, dynamic>,
      ),
      eur: CurrencyModel.fromJson(
        'EUR',
        currencies['EUR'] as Map<String, dynamic>,
      ),
      updatedAt: DateTime.now(),
    );
  }
}
