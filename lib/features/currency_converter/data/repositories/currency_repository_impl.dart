import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_remote_data_source.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;

  CurrencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExchangeRates>> getExchangeRates() async {
    try {
      final result = await remoteDataSource.getExchangeRates();
      return Right(result);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
