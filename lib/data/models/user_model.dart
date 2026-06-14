enum UserRole { customer, barber }

class UserModel {
  final String id;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    this.role = UserRole.customer,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        phone: json['phone'],
        fullName: json['full_name'],
        avatarUrl: json['avatar_url'],
        role: UserRole.values.firstWhere(
          (r) => r.name == (json['role'] ?? 'customer'),
          orElse: () => UserRole.customer,
        ),
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role.name,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    UserRole? role,
  }) =>
      UserModel(
        id: id,
        phone: phone,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        createdAt: createdAt,
      );
}
