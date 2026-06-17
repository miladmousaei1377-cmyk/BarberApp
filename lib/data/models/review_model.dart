class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String salonId;
  final String? appointmentId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.salonId,
    this.appointmentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'],
        userId: json['user_id'],
        userName: json['user_name'],
        userAvatar: json['user_avatar'],
        salonId: json['salon_id'],
        appointmentId: json['appointment_id'],
        rating: json['rating'],
        comment: json['comment'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_avatar': userAvatar,
        'salon_id': salonId,
        'appointment_id': appointmentId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };
}
