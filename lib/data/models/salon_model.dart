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
  final String? phone;
  final bool isActive;
  final String city;
  final String openTime;
  final String closeTime;

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
    this.phone,
    this.isActive = true,
    this.city = '',
    this.openTime = '09:00',
    this.closeTime = '21:00',
  });

  SalonModel copyWith({
    String? name,
    String? description,
    String? address,
    double? lat,
    double? lng,
    SalonCategory? category,
    String? phone,
    bool? isActive,
    String? city,
    String? openTime,
    String? closeTime,
    List<String>? images,
  }) =>
      SalonModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        coverImage: coverImage,
        rating: rating,
        reviewCount: reviewCount,
        isVerified: isVerified,
        category: category ?? this.category,
        ownerId: ownerId,
        images: images ?? this.images,
        phone: phone ?? this.phone,
        isActive: isActive ?? this.isActive,
        city: city ?? this.city,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
      );

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'address': address,
        'lat': lat,
        'lng': lng,
        'cover_image': coverImage,
        'rating': rating,
        'review_count': reviewCount,
        'is_verified': isVerified,
        'category': category.name,
        'owner_id': ownerId,
        'images': images,
        'phone': phone,
        'is_active': isActive,
        'city': city,
        'open_time': openTime,
        'close_time': closeTime,
      };

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
        phone: json['phone'],
        isActive: json['is_active'] ?? true,
        city: json['city'] ?? '',
        openTime: json['open_time'] ?? '09:00',
        closeTime: json['close_time'] ?? '21:00',
      );
}
