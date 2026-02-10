import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/currency_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<ExchangeRatesModel> getExchangeRates();
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final Dio dio;

  CurrencyRemoteDataSourceImpl({required this.dio});

  @override
  Future<ExchangeRatesModel> getExchangeRates() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.financeUrl,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ExchangeRatesModel.fromJson(response.data!);
      } else {
        throw ServerException(
          message: 'Erro no servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        message: e.message ?? 'Erro desconhecido',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
