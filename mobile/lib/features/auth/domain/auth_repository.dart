import 'models/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> signInWithGoogle();

  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> signUp({required String email, required String password});

  Future<void> signOut();

  Future<AuthSession?> getStoredSession();
}
