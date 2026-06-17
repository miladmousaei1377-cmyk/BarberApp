import '../models/user_model.dart';
import '../models/salon_model.dart';
import '../models/stylist_model.dart';
import '../models/service_model.dart';
import '../models/review_model.dart';
import '../models/appointment_model.dart';
import '../models/working_hours_model.dart';

class MockData {
  static List<UserModel> users = [];
  static List<SalonModel> salons = [];
  static List<StylistModel> stylists = [];
  static List<ServiceModel> services = [];
  static List<ReviewModel> reviews = [];
  static List<AppointmentModel> appointments = [];
  static List<WorkingHoursModel> workingHours = [];

  static void Function()? onDataChanged;

  static void init() {
    _initUsers();
    _initSalons();
    _initStylists();
    _initServices();
    _initWorkingHours();
    _initReviews();
    _initAppointments();
  }

  static void _initUsers() {
    users = [
      UserModel(
        id: 'u_demo1',
        fullName: 'علی رضایی',
        phone: '09123456789',
        email: 'ali@demo.com',
        password: '123456',
        role: UserRole.customer,
        createdAt: DateTime(2024, 1, 1),
      ),
      UserModel(
        id: 'u_demo2',
        fullName: 'سارا محمدی',
        phone: '09987654321',
        email: 'sara@demo.com',
        password: '123456',
        role: UserRole.customer,
        createdAt: DateTime(2024, 1, 1),
      ),
      UserModel(
        id: 'b_demo1',
        fullName: 'حسین نوری',
        phone: '09111111111',
        email: 'barber@demo.com',
        password: '123456',
        role: UserRole.barber,
        stylistStatus: 'approved',
        createdAt: DateTime(2024, 1, 1),
      ),
      UserModel(
        id: 'b_demo2',
        fullName: 'مریم صادقی',
        phone: '09222222222',
        email: 'stylist@demo.com',
        password: '123456',
        role: UserRole.barber,
        stylistStatus: 'pending',
        createdAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  static void _initSalons() {
    salons = [];
  }

  static void _initStylists() {
    stylists = [];
  }

  static void _initServices() {
    services = [];
  }

  static void _initWorkingHours() {
    for (var stylist in stylists) {
      for (int day = 0; day < 7; day++) {
        workingHours.add(WorkingHoursModel(
          id: 'wh_${stylist.id}_$day',
          stylistId: stylist.id,
          dayOfWeek: day,
          startTime: day == 6 ? '10:00' : '09:00',
          endTime: day == 6 ? '18:00' : '21:00',
          isOff: false,
        ));
      }
    }
  }

  static void _initReviews() {
    reviews = [];
  }

  static void _initAppointments() {
    appointments = [];
  }

  // Query methods
  static List<SalonModel> getSalonsByCategory(String? category) {
    if (category == null || category == 'all') return salons;
    return salons.where((s) => s.categoryValue == category).toList();
  }

  static List<ServiceModel> getServicesBySalon(String salonId) {
    return services.where((s) => s.salonId == salonId).toList();
  }

  static List<StylistModel> getStylistsBySalon(String salonId) {
    return stylists.where((s) => s.salonId == salonId).toList();
  }

  static List<ReviewModel> getReviewsBySalon(String salonId) {
    return reviews.where((r) => r.salonId == salonId).toList();
  }

  static List<AppointmentModel> getAppointmentsByUser(String userId) {
    return appointments.where((a) => a.userId == userId).toList();
  }

  static List<String> getAvailableSlots(
    String salonId,
    String? stylistId,
    DateTime date,
    int totalDurationMinutes,
  ) {
    final slots = <String>[];
    // working hours: Sat-Thu 9:00-21:00, Fri 10:00-18:00
    final isFriday = date.weekday == DateTime.friday;
    final startHour = isFriday ? 10 : 9;
    final endHour = isFriday ? 18 : 21;

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final slotTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final slotEnd = _addMinutes(slotTime, totalDurationMinutes);

        if (_timeToMinutes(slotEnd) <= endHour * 60) {
          // check for conflicts
          bool hasConflict = appointments.any((a) {
            if (a.salonId != salonId) return false;
            if (stylistId != null && a.stylistId != stylistId) return false;
            if (a.date.year != date.year ||
                a.date.month != date.month ||
                a.date.day != date.day) return false;
            if (a.status == AppointmentStatus.cancelled) return false;

            final existStart = _timeToMinutes(a.startTime);
            final existEnd = _timeToMinutes(a.endTime);
            final newStart = _timeToMinutes(slotTime);
            final newEnd = _timeToMinutes(slotEnd);

            return !(newEnd <= existStart || newStart >= existEnd);
          });

          if (!hasConflict) {
            // check if slot is in the past
            final slotDateTime = DateTime(date.year, date.month, date.day, hour, minute);
            if (slotDateTime.isAfter(DateTime.now())) {
              slots.add(slotTime);
            }
          }
        }
      }
    }
    return slots;
  }

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _addMinutes(String time, int minutes) {
    final totalMinutes = _timeToMinutes(time) + minutes;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  static AppointmentModel addAppointment(AppointmentModel appointment) {
    appointments.add(appointment);
    onDataChanged?.call();
    return appointment;
  }

  static void deleteAppointment(String appointmentId) {
    appointments.removeWhere((a) => a.id == appointmentId);
    onDataChanged?.call();
  }

  static bool cancelAppointment(String appointmentId, {String? reason}) {
    final idx = appointments.indexWhere((a) => a.id == appointmentId);
    if (idx == -1) return false;
    appointments[idx] = appointments[idx].copyWith(
      status: AppointmentStatus.cancelled,
      cancelReason: (reason != null && reason.trim().isNotEmpty) ? reason.trim() : null,
    );
    onDataChanged?.call();
    return true;
  }
}
