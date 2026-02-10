import 'package:equatable/equatable.dart';

enum CurrencyType { brl, usd, eur }

class ConvertCurrency {
  ConversionResult call(ConvertCurrencyParams params) {
    final double amountInBrl = _toBrl(
      params.amount,
      params.fromCurrency,
      params.usdRate,
      params.eurRate,
    );

    return ConversionResult(
      brl: amountInBrl,
      usd: amountInBrl / params.usdRate,
      eur: amountInBrl / params.eurRate,
    );
  }

  double _toBrl(
    double amount,
    CurrencyType currency,
    double usdRate,
    double eurRate,
  ) {
    switch (currency) {
      case CurrencyType.brl:
        return amount;
      case CurrencyType.usd:
        return amount * usdRate;
      case CurrencyType.eur:
        return amount * eurRate;
    }
  }
}

class ConvertCurrencyParams extends Equatable {
  final double amount;
  final CurrencyType fromCurrency;
  final double usdRate;
  final double eurRate;

  const ConvertCurrencyParams({
    required this.amount,
    required this.fromCurrency,
    required this.usdRate,
    required this.eurRate,
  });

  @override
  List<Object?> get props => [amount, fromCurrency, usdRate, eurRate];
}

class ConversionResult extends Equatable {
  final double brl;
  final double usd;
  final double eur;

  const ConversionResult({
    required this.brl,
    required this.usd,
    required this.eur,
  });

  @override
  List<Object?> get props => [brl, usd, eur];
}
