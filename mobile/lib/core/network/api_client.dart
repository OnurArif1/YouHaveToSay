import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_token_storage.dart';
import 'firebase_token_provider.dart';

Dio createApiClient({
  required AppConfig config,
  required AuthTokenStorage tokenStorage,
  required FirebaseTokenProvider firebaseTokenProvider,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isAuthExchange = options.path.contains('/api/auth/register-or-login');

        if (isAuthExchange) {
          try {
            final firebaseToken = await firebaseTokenProvider.getIdToken();
            options.headers['X-Firebase-Token'] = firebaseToken;
          } catch (_) {
            // Body carries firebaseToken for register-or-login.
          }
        } else {
          final apiToken = await tokenStorage.getAccessToken();
          if (apiToken != null && apiToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $apiToken';
          }
        }

        handler.next(options);
      },
    ),
  );

  return dio;
}
