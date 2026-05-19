import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/google_auth_service.dart';
import '../../domain/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final session = await _authRepository.getStoredSession();
    if (session != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        email: session.email.isEmpty ? null : session.email,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final session = await _authRepository.signInWithGoogle();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        email: session.email,
        clearError: true,
      ));
    } on AuthCancelledException {
      emit(state.copyWith(isLoading: false, clearError: true));
    } on UnsupportedError {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'google_auth_requires_firebase',
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'google_auth_error',
      ));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authenticate(
      emit,
      () => _authRepository.signIn(email: event.email, password: event.password),
      event.email,
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authenticate(
      emit,
      () => _authRepository.signUp(email: event.email, password: event.password),
      event.email,
    );
  }

  Future<void> _authenticate(
    Emitter<AuthState> emit,
    Future<dynamic> Function() action,
    String email,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final session = await action();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        email: session.email,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'auth_error',
      ));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
