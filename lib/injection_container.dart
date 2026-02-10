import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'features/currency_converter/data/datasources/currency_remote_data_source.dart';
import 'features/currency_converter/data/repositories/currency_repository_impl.dart';
import 'features/currency_converter/domain/repositories/currency_repository.dart';
import 'features/currency_converter/domain/usecases/convert_currency.dart';
import 'features/currency_converter/domain/usecases/get_exchange_rates.dart';
import 'features/currency_converter/presentation/providers/currency_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Providers/Notifiers
  sl.registerFactory(
    () => CurrencyNotifier(
      getExchangeRates: sl(),
      convertCurrency: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetExchangeRates(sl()));
  sl.registerLazySingleton(() => ConvertCurrency());

  // Repositories
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSourceImpl(dio: sl()),
  );

  // External
  sl.registerLazySingleton(() => Dio());
}
