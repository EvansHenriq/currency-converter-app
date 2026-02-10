import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

class GetExchangeRates implements UseCase<ExchangeRates, NoParams> {
  final CurrencyRepository repository;

  GetExchangeRates(this.repository);

  @override
  Future<Either<Failure, ExchangeRates>> call(NoParams params) {
    return repository.getExchangeRates();
  }
}
