class ServiceModel {
  final String id;
  final String salonId;
  final String name;
  final int durationMinutes;
  final int price;
  final String category;

  const ServiceModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.durationMinutes,
    required this.price,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        salonId: json['salon_id'],
        name: json['name'],
        durationMinutes: json['duration_minutes'],
        price: json['price'],
        category: json['category'],
      );
}
