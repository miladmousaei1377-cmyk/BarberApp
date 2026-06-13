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

  static String dayName(int day) {
    const days = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
    return days[day];
  }
}
