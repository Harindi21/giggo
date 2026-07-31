class UserModel {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String role;
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    required this.emailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String? ?? '',
    fullName: json['fullName'] as String,
    role: json['role'] as String,
    emailVerified: json['emailVerified'] as bool? ?? false,
  );
}
