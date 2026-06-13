class UserModel {
  final String id;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        phone: json['phone'],
        fullName: json['full_name'],
        avatarUrl: json['avatar_url'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({String? fullName, String? avatarUrl}) => UserModel(
        id: id,
        phone: phone,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );
}
