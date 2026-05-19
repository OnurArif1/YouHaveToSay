import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/auth_token_storage.dart';
import '../../../core/network/firebase_token_provider.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_session.dart';
import 'google_auth_service.dart';
import 'models/auth_response_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required Dio dio,
    required AuthTokenStorage tokenStorage,
    required FirebaseTokenProvider firebaseTokenProvider,
    required AppConfig config,
    GoogleAuthService? googleAuthService,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _firebaseTokenProvider = firebaseTokenProvider,
        _config = config,
        _googleAuthService = googleAuthService ?? GoogleAuthService();

  final Dio _dio;
  final AuthTokenStorage _tokenStorage;
  final FirebaseTokenProvider _firebaseTokenProvider;
  final AppConfig _config;
  final GoogleAuthService _googleAuthService;

  @override
  Future<AuthSession> signInWithGoogle() async {
    if (_config.useDevAuth) {
      throw UnsupportedError('google_auth_requires_firebase');
    }

    await _googleAuthService.signIn();
    final firebaseToken = await _firebaseTokenProvider.getIdToken();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return _exchangeToken(firebaseToken, email);
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) =>
      _authenticate(email: email, password: password, isSignUp: false);

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) =>
      _authenticate(email: email, password: password, isSignUp: true);

  Future<AuthSession> _authenticate({
    required String email,
    required String password,
    required bool isSignUp,
  }) async {
    if (_config.useDevAuth) {
      _firebaseTokenProvider.setDevCredentials(email: email.trim());
    } else {
      if (isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      }
    }

    final firebaseToken = await _firebaseTokenProvider.getIdToken();
    return _exchangeToken(firebaseToken, email.trim());
  }

  Future<AuthSession> _exchangeToken(String firebaseToken, String email) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register-or-login',
      data: {'firebaseToken': firebaseToken},
    );

    final dto = AuthResponseDto.fromJson(response.data!);
    await _tokenStorage.saveAccessToken(dto.accessToken);

    return AuthSession(
      accessToken: dto.accessToken,
      email: dto.user.email.isNotEmpty ? dto.user.email : email,
      userId: dto.user.id,
    );
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
    if (!_config.useDevAuth) {
      await _googleAuthService.signOut();
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return AuthSession(
      accessToken: token,
      email: '',
      userId: '',
    );
  }
}
