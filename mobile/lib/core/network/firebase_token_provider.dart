import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTokenProvider {
  FirebaseTokenProvider({required bool useDevAuth}) : _useDevAuth = useDevAuth;

  final bool _useDevAuth;
  String? _devEmail;

  void setDevCredentials({required String email}) {
    _devEmail = email;
  }

  Future<String> getIdToken() async {
    if (_useDevAuth) {
      final email = _devEmail;
      if (email == null || email.isEmpty) {
        throw StateError('Dev auth requires an email.');
      }
      final uid = email.hashCode.abs().toString();
      return 'dev:$uid:$email';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No authenticated Firebase user.');
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Could not obtain Firebase ID token.');
    }
    return token;
  }
}
