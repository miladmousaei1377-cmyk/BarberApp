enum AppointmentStatus { pending, confirmed, cancelled, done }

class AppointmentModel {
  final String id;
  final String userId;
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

  AppointmentModel copyWith({AppointmentStatus? status}) => AppointmentModel(
        id: id,
        userId: userId,
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
