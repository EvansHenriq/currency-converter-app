import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

abstract class CurrencyLocalDataSource {
  /// Returns the cached list of active currency codes.
  /// Throws [CacheException] if no cached data is present.
  List<String> getCachedActiveCurrencies();

  /// Saves the list of active currency codes to local storage.
  Future<void> cacheActiveCurrencies(List<String> currencies);
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _activeCurrenciesKey = 'ACTIVE_CURRENCIES';

  CurrencyLocalDataSourceImpl({required this.sharedPreferences});

  @override
  List<String> getCachedActiveCurrencies() {
    final cachedList = sharedPreferences.getStringList(_activeCurrenciesKey);
    if (cachedList != null && cachedList.length >= 2) {
      return cachedList;
    }
    throw const CacheException(message: 'No cached active currencies found');
  }

  @override
  Future<void> cacheActiveCurrencies(List<String> currencies) async {
    final success = await sharedPreferences.setStringList(
      _activeCurrenciesKey,
      currencies,
    );
    if (!success) {
      throw const CacheException(message: 'Failed to cache active currencies');
    }
  }
}
