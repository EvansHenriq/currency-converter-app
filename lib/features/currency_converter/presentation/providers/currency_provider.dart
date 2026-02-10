import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/currency.dart';
import '../../domain/usecases/convert_currency.dart';
import '../../domain/usecases/get_exchange_rates.dart';
import '../../../../injection_container.dart';

// State classes
sealed class CurrencyState {}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final ExchangeRates rates;
  final ConversionResult? conversionResult;

  CurrencyLoaded({required this.rates, this.conversionResult});

  CurrencyLoaded copyWith({
    ExchangeRates? rates,
    ConversionResult? conversionResult,
  }) {
    return CurrencyLoaded(
      rates: rates ?? this.rates,
      conversionResult: conversionResult,
    );
  }
}

class CurrencyError extends CurrencyState {
  final String message;

  CurrencyError(this.message);
}

// Notifier
class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final GetExchangeRates getExchangeRates;
  final ConvertCurrency convertCurrency;

  CurrencyNotifier({
    required this.getExchangeRates,
    required this.convertCurrency,
  }) : super(CurrencyInitial());

  Future<void> fetchRates() async {
    state = CurrencyLoading();

    final result = await getExchangeRates(const NoParams());

    result.fold(
      (failure) => state = CurrencyError(failure.message),
      (rates) => state = CurrencyLoaded(rates: rates),
    );
  }

  void convert(double amount, CurrencyType fromCurrency) {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      final result = convertCurrency(
        ConvertCurrencyParams(
          amount: amount,
          fromCurrency: fromCurrency,
          usdRate: currentState.rates.usd.buyRate,
          eurRate: currentState.rates.eur.buyRate,
        ),
      );

      state = currentState.copyWith(conversionResult: result);
    }
  }

  void clearConversion() {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      state = CurrencyLoaded(rates: currentState.rates);
    }
  }
}

// Provider
final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) => sl<CurrencyNotifier>(),
);
