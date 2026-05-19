import '../../firebase_options.dart';

bool get isProductionFirebaseConfigured {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    return options.apiKey.isNotEmpty && !options.apiKey.contains('REPLACE');
  } catch (_) {
    return false;
  }
}

bool get isFirebaseReady => isProductionFirebaseConfigured;
