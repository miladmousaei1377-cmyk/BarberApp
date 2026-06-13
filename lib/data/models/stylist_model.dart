class StylistModel {
  final String id;
  final String salonId;
  final String name;
  final String? avatar;
  final String specialty;
  final double rating;

  const StylistModel({
    required this.id,
    required this.salonId,
    required this.name,
    this.avatar,
    required this.specialty,
    required this.rating,
  });

  factory StylistModel.fromJson(Map<String, dynamic> json) => StylistModel(
        id: json['id'],
        salonId: json['salon_id'],
        name: json['name'],
        avatar: json['avatar'],
        specialty: json['specialty'],
        rating: json['rating'].toDouble(),
      );
}
