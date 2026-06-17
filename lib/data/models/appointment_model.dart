enum AppointmentStatus { pending, confirmed, cancelled, done }

class AppointmentModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userPhone;
  final String salonId;
  final String salonName;
  final String salonAddress;
  final String? stylistId;
  final String? stylistName;
  final List<String> serviceIds;
  final List<String> serviceNames;
  final DateTime date;
  final String startTime;
  final String endTime;
  final AppointmentStatus status;
  final int totalPrice;
  final String? notes;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userPhone,
    required this.salonId,
    required this.salonName,
    required this.salonAddress,
    this.stylistId,
    this.stylistName,
    required this.serviceIds,
    required this.serviceNames,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.pending:
        return 'در انتظار';
      case AppointmentStatus.confirmed:
        return 'تأیید شده';
      case AppointmentStatus.cancelled:
        return 'لغو شده';
      case AppointmentStatus.done:
        return 'انجام شده';
    }
  }

  bool get canCancel {
    final appointmentDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(startTime.split(':')[0]),
      int.parse(startTime.split(':')[1]),
    );
    return appointmentDateTime.difference(DateTime.now()).inHours >= 2 &&
        (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed);
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
        id: json['id'],
        userId: json['user_id'],
        userName: json['user_name'],
        userPhone: json['user_phone'],
        salonId: json['salon_id'],
        salonName: json['salon_name'],
        salonAddress: json['salon_address'],
        stylistId: json['stylist_id'],
        stylistName: json['stylist_name'],
        serviceIds: List<String>.from(json['service_ids'] ?? []),
        serviceNames: List<String>.from(json['service_names'] ?? []),
        date: DateTime.parse(json['date']),
        startTime: json['start_time'],
        endTime: json['end_time'],
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => AppointmentStatus.pending,
        ),
        totalPrice: json['total_price'],
        notes: json['notes'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_phone': userPhone,
        'salon_id': salonId,
        'salon_name': salonName,
        'salon_address': salonAddress,
        'stylist_id': stylistId,
        'stylist_name': stylistName,
        'service_ids': serviceIds,
        'service_names': serviceNames,
        'date': date.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'status': status.name,
        'total_price': totalPrice,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  AppointmentModel copyWith({AppointmentStatus? status}) => AppointmentModel(
        id: id,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        salonId: salonId,
        salonName: salonName,
        salonAddress: salonAddress,
        stylistId: stylistId,
        stylistName: stylistName,
        serviceIds: serviceIds,
        serviceNames: serviceNames,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status ?? this.status,
        totalPrice: totalPrice,
        notes: notes,
        createdAt: createdAt,
      );
}


