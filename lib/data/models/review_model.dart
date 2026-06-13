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
}
