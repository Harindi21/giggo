class RegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String role;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'role': role,
  };
}
