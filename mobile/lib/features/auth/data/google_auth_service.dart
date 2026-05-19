import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/config/google_oauth_config.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

class FirebaseNotConfiguredException implements Exception {
  const FirebaseNotConfiguredException();
}

/// Firebase Console'da Google provider etkin değil.
class GoogleAuthNotEnabledException implements Exception {
  const GoogleAuthNotEnabledException();
}

class GoogleAuthService {
  GoogleAuthService({this.serverClientId});

  final String? serverClientId;
  bool _initialized = false;
  GoogleOAuthConfig? _oauthConfig;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (!isProductionFirebaseConfigured) {
      throw const FirebaseNotConfiguredException();
    }

    _oauthConfig = GoogleOAuthConfig.fromFirebaseOptions();
    if (!_oauthConfig!.isConfigured) {
      throw const GoogleAuthNotEnabledException();
    }

    await GoogleSignIn.instance.initialize(
      clientId: _oauthConfig!.iosClientId,
      serverClientId: serverClientId,
    );
    _initialized = true;
  }

  Future<UserCredential> signIn() async {
    await _ensureInitialized();

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google ID token alınamadı.');
      }

      return FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!_initialized) {
      await FirebaseAuth.instance.signOut();
      return;
    }
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
