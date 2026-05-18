import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.email,
    required this.userId,
  });

  final String accessToken;
  final String email;
  final String userId;

  @override
  List<Object?> get props => [accessToken, email, userId];
}
