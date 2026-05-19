import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_config.dart';
import 'core/di/injection.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final firebaseReady = isFirebaseConfigured;

  // firebase_options.dart doldurulmamışsa çökme yerine dev auth'a düş
  final effectiveConfig = AppConfig(
    apiBaseUrl: config.apiBaseUrl,
    useDevAuth: config.useDevAuth || !firebaseReady,
  );

  if (firebaseReady) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[YouHaveToSay] Firebase başlatıldı.');
  } else {
    debugPrint(
      '[YouHaveToSay] Firebase yapılandırılmamış (REPLACE_ME). '
      'Google girişi için: cd mobile && flutterfire configure',
    );
  }

  if (effectiveConfig.useDevAuth) {
    debugPrint(
      '[YouHaveToSay] Dev/e-posta giriş modu. '
      'Google için: flutter run (flutterfire configure sonrası)',
    );
  }

  await configureDependencies(effectiveConfig);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      startLocale: const Locale('tr'),
      child: const YouHaveToSayApp(),
    ),
  );
}
