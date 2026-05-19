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
  final firebaseReady = isFirebaseReady;

  if (firebaseReady) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[YouHaveToSay] Firebase başlatıldı — gerçek Google girişi aktif.');
  } else {
    debugPrint(
      '[YouHaveToSay] Firebase yapılandırılmamış. '
      'Gerçek Google hesap seçici için: ./scripts/setup-google-signin.sh',
    );
  }

  final effectiveConfig = config.copyWith(firebaseConfigured: firebaseReady);

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
