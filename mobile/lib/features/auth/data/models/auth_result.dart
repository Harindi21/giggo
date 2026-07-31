import 'user_model.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}
