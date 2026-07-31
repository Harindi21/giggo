class ApiConfig {
  ApiConfig._();

  /// IMPORTANT: how the app reaches your backend depends on where it runs:
  ///  - Android emulator  : http://10.0.2.2:8080   (10.0.2.2 = your PC's localhost)
  ///  - iOS simulator/web : http://localhost:8080
  ///  - Physical phone    : use your PC's LAN IP, e.g. http://192.168.1.5:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String apiPrefix = '/api/v1';
}
