import 'dart:io';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useDevAuth,
    required this.firebaseConfigured,
    this.googleWebClientId,
  });

  final String apiBaseUrl;
  final bool useDevAuth;
  final bool firebaseConfigured;
  final String? googleWebClientId;

  bool get canUseGoogleSignIn => firebaseConfigured && !useDevAuth;

  static AppConfig fromEnvironment() {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    const envUseDevAuth = String.fromEnvironment('USE_DEV_AUTH');
    const webClientId = String.fromEnvironment('FIREBASE_WEB_CLIENT_ID');

    final useDevAuth = envUseDevAuth.isNotEmpty && envUseDevAuth == 'true';

    final defaultHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final baseUrl = envUrl.isNotEmpty ? envUrl : 'http://$defaultHost:5106';

    return AppConfig(
      apiBaseUrl: baseUrl,
      useDevAuth: useDevAuth,
      firebaseConfigured: false,
      googleWebClientId: webClientId.isNotEmpty ? webClientId : null,
    );
  }

  AppConfig copyWith({
    String? apiBaseUrl,
    bool? useDevAuth,
    bool? firebaseConfigured,
    String? googleWebClientId,
  }) {
    return AppConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      useDevAuth: useDevAuth ?? this.useDevAuth,
      firebaseConfigured: firebaseConfigured ?? this.firebaseConfigured,
      googleWebClientId: googleWebClientId ?? this.googleWebClientId,
    );
  }
}
