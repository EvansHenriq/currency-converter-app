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
  final Currency usd;
  final Currency eur;
  final DateTime updatedAt;

  const ExchangeRates({
    required this.usd,
    required this.eur,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [usd, eur, updatedAt];
}
