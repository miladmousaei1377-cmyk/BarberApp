class WorkingHoursModel {
  final String id;
  final String stylistId;
  final int dayOfWeek; // 0=Saturday, 6=Friday in Iran
  final String startTime;
  final String endTime;
  final bool isOff;

  const WorkingHoursModel({
    required this.id,
    required this.stylistId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isOff,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) => WorkingHoursModel(
        id: json['id'],
        stylistId: json['stylist_id'],
        dayOfWeek: json['day_of_week'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        isOff: json['is_off'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stylist_id': stylistId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'is_off': isOff,
      };

  static String dayName(int day) {
    const days = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
    return days[day];
  }
}
