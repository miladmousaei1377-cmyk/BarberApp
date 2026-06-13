enum SalonCategory { male, female, unisex }

class SalonModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final String? coverImage;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final SalonCategory category;
  final String ownerId;
  final List<String> images;

  const SalonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    this.coverImage,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.category,
    required this.ownerId,
    this.images = const [],
  });

  String get categoryLabel {
    switch (category) {
      case SalonCategory.male:
        return 'مردانه';
      case SalonCategory.female:
        return 'زنانه';
      case SalonCategory.unisex:
        return 'یونیسکس';
    }
  }

  String get categoryValue {
    switch (category) {
      case SalonCategory.male:
        return 'male';
      case SalonCategory.female:
        return 'female';
      case SalonCategory.unisex:
        return 'unisex';
    }
  }

  factory SalonModel.fromJson(Map<String, dynamic> json) => SalonModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        address: json['address'],
        lat: json['lat'].toDouble(),
        lng: json['lng'].toDouble(),
        coverImage: json['cover_image'],
        rating: json['rating'].toDouble(),
        reviewCount: json['review_count'],
        isVerified: json['is_verified'],
        category: SalonCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => SalonCategory.unisex,
        ),
        ownerId: json['owner_id'],
        images: List<String>.from(json['images'] ?? []),
      );
}
