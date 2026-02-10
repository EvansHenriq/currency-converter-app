import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../data/datasources/currency_local_data_source.dart';
import '../../domain/entities/currency.dart';
import '../../domain/usecases/convert_currency.dart';
import '../../domain/usecases/get_exchange_rates.dart';

// State classes
sealed class CurrencyState {}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final ExchangeRates rates;
  final List<String> activeCurrencies;
  final ConversionResult? conversionResult;

  CurrencyLoaded({
    required this.rates,
    required this.activeCurrencies,
    this.conversionResult,
  });

  List<String> get availableToAdd {
    final allCodes = [
      'BRL',
      ...rates.availableCodes,
    ];
    return allCodes.where((code) => !activeCurrencies.contains(code)).toList();
  }

  bool get canDelete => activeCurrencies.length > 2;

  CurrencyLoaded copyWith({
    ExchangeRates? rates,
    List<String>? activeCurrencies,
    ConversionResult? conversionResult,
    bool clearConversion = false,
  }) {
    return CurrencyLoaded(
      rates: rates ?? this.rates,
      activeCurrencies: activeCurrencies ?? this.activeCurrencies,
      conversionResult: clearConversion ? null : (conversionResult ?? this.conversionResult),
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
  final CurrencyLocalDataSource localDataSource;

  static const List<String> _defaultCurrencies = [
    'USD',
    'EUR',
  ];

  CurrencyNotifier({
    required this.getExchangeRates,
    required this.convertCurrency,
    required this.localDataSource,
  }) : super(CurrencyInitial());

  Future<void> fetchRates() async {
    state = CurrencyLoading();

    final result = await getExchangeRates(const NoParams());

    result.fold(
      (failure) => state = CurrencyError(failure.message),
      (rates) {
        List<String> currencies;
        try {
          currencies = localDataSource.getCachedActiveCurrencies();
        } catch (_) {
          currencies = _defaultCurrencies;
        }
        state = CurrencyLoaded(
          rates: rates,
          activeCurrencies: currencies,
        );
      },
    );
  }

  void convert(double amount, String fromCurrency) {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      final Map<String, double> ratesMap = {};
      for (final code in currentState.activeCurrencies) {
        ratesMap[code] = currentState.rates.rateFor(code);
      }

      final result = convertCurrency(
        ConvertCurrencyParams(
          amount: amount,
          fromCurrency: fromCurrency,
          fromRate: currentState.rates.rateFor(fromCurrency),
          rates: ratesMap,
        ),
      );

      state = currentState.copyWith(conversionResult: result);
    }
  }

  void clearConversion() {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      state = currentState.copyWith(clearConversion: true);
    }
  }

  void addCurrency(String code) {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      if (currentState.activeCurrencies.contains(code)) return;
      final updated = [
        ...currentState.activeCurrencies,
        code,
      ];
      state = currentState.copyWith(
        activeCurrencies: updated,
        clearConversion: true,
      );
      _persistActiveCurrencies(updated);
    }
  }

  void removeCurrency(String code) {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      if (!currentState.canDelete) return;
      final updated = currentState.activeCurrencies.where((c) => c != code).toList();
      if (updated.length < 2) return;
      state = currentState.copyWith(
        activeCurrencies: updated,
        clearConversion: true,
      );
      _persistActiveCurrencies(updated);
    }
  }

  void _persistActiveCurrencies(List<String> currencies) {
    localDataSource.cacheActiveCurrencies(currencies);
  }
}

// Provider
final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) => sl<CurrencyNotifier>(),
);
