import 'dart:io';

import 'package:flutter/foundation.dart';

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

    // Debug build'lerde varsayılan: Firebase olmadan dev token
    final useDevAuth = envUseDevAuth.isEmpty
        ? kDebugMode
        : envUseDevAuth == 'true';

    final defaultHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final baseUrl =
        envUrl.isNotEmpty ? envUrl : 'http://$defaultHost:5106';

    return AppConfig(apiBaseUrl: baseUrl, useDevAuth: useDevAuth);
  }
}
