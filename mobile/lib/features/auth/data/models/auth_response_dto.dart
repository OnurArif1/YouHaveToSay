class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final DateTime expiresAt;
  final UserDto user;
}

class UserDto {
  const UserDto({required this.id, required this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'].toString(),
      email: json['email'] as String,
    );
  }

  final String id;
  final String email;
}
