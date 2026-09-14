class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8081';

  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
}