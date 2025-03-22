class UserModel {
  final String name;
  final String email;
  final String role;
  final bool admin;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    this.admin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      admin: map['admin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'admin': admin,
    };
  }
}
