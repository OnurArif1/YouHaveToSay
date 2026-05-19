import '../../firebase_options.dart';

/// Google OAuth yapılandırması (flutterfire + Google provider etkin olmalı).
class GoogleOAuthConfig {
  const GoogleOAuthConfig({
    this.iosClientId,
  });

  final String? iosClientId;

  bool get isConfigured => iosClientId != null && iosClientId!.isNotEmpty;

  static GoogleOAuthConfig fromFirebaseOptions() {
    final clientId = DefaultFirebaseOptions.ios.iosClientId;
    return GoogleOAuthConfig(
      iosClientId: clientId != null && clientId.isNotEmpty ? clientId : null,
    );
  }
}
