import '../../firebase_options.dart';

bool get isFirebaseConfigured {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    return options.apiKey.isNotEmpty && !options.apiKey.contains('REPLACE');
  } catch (_) {
    return false;
  }
}
