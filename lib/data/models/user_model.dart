enum UserRole { customer, barber }

class UserModel {
  final String id;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;
  final String? email;
  final String? password;
  final String? stylistStatus; // 'pending', 'approved'

  const UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    this.role = UserRole.customer,
    required this.createdAt,
    this.email,
    this.password,
    this.stylistStatus,
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
        email: json['email'],
        password: json['password'],
        stylistStatus: json['stylist_status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role.name,
        'created_at': createdAt.toIso8601String(),
        'email': email,
        'password': password,
        'stylist_status': stylistStatus,
      };

  static const _unset = Object();

  UserModel copyWith({
    String? fullName,
    String? phone,
    Object? avatarUrl = _unset,
    UserRole? role,
    String? email,
    String? password,
    String? stylistStatus,
  }) =>
      UserModel(
        id: id,
        phone: phone ?? this.phone,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl == _unset ? this.avatarUrl : avatarUrl as String?,
        role: role ?? this.role,
        createdAt: createdAt,
        email: email ?? this.email,
        password: password ?? this.password,
        stylistStatus: stylistStatus ?? this.stylistStatus,
      );
}
