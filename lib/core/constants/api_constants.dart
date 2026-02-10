abstract class ApiConstants {
  static const String baseUrl = 'https://api.hgbrasil.com';
  static const String financeEndpoint = '/finance';
  static const String apiKey = '8fb5eb17';

  static String get financeUrl => '$baseUrl$financeEndpoint?key=$apiKey';
}
