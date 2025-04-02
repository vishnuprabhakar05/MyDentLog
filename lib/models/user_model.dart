class UserModel {
  final String name;
  final String email;
  final String role;
  final bool admin;
  final String phone;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    this.admin = false,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      admin: map['admin'] ?? false,
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'admin': admin,
      'phone': phone
    };
  }
}
