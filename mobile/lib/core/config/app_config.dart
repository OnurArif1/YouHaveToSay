import 'dart:io';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useDevAuth,
  });

  final String apiBaseUrl;
  final bool useDevAuth;

  static AppConfig fromEnvironment() {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    const envUseDevAuth = String.fromEnvironment('USE_DEV_AUTH');

    // Varsayılan: Google Sign-In (Firebase). Dev token için: USE_DEV_AUTH=true
    final useDevAuth =
        envUseDevAuth.isNotEmpty && envUseDevAuth == 'true';

    final defaultHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final baseUrl =
        envUrl.isNotEmpty ? envUrl : 'http://$defaultHost:5106';

    return AppConfig(apiBaseUrl: baseUrl, useDevAuth: useDevAuth);
  }
}
