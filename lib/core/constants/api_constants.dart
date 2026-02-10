abstract class ApiConstants {
  static const String baseUrl = 'https://api.hgbrasil.com';
  static const String financeEndpoint = '/finance';

  static String get financeUrl => '$baseUrl$financeEndpoint';
}
