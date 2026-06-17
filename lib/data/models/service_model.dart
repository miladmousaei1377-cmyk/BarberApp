class ServiceModel {
  final String id;
  final String salonId;
  final String name;
  final int durationMinutes;
  final int price;
  final String category;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.durationMinutes,
    required this.price,
    required this.category,
    this.isActive = true,
  });

  ServiceModel copyWith({
    String? name,
    int? durationMinutes,
    int? price,
    String? category,
    bool? isActive,
  }) =>
      ServiceModel(
        id: id,
        salonId: salonId,
        name: name ?? this.name,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        price: price ?? this.price,
        category: category ?? this.category,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'salon_id': salonId,
        'name': name,
        'duration_minutes': durationMinutes,
        'price': price,
        'category': category,
        'is_active': isActive,
      };

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        salonId: json['salon_id'],
        name: json['name'],
        durationMinutes: json['duration_minutes'],
        price: json['price'],
        category: json['category'],
        isActive: json['is_active'] ?? true,
      );
}
