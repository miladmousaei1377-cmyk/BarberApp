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
    salons = [
      // Demo salons with real Iranian coordinates
      SalonModel(
        id: 'salon_demo1',
        name: 'آرایشگاه خاص',
        description: 'آرایشگاه مردانه مدرن در قلب تهران با بیش از ۱۰ سال سابقه',
        address: 'تهران، جردن، خیابان اسفندیار',
        lat: 35.7652,
        lng: 51.4122,
        rating: 4.8,
        reviewCount: 124,
        isVerified: true,
        category: SalonCategory.male,
        ownerId: 'b_demo1',
        city: 'تهران',
        openTime: '09:00',
        closeTime: '21:00',
        phone: '02122001100',
      ),
      SalonModel(
        id: 'salon_demo2',
        name: 'سالن زیبایی نگار',
        description: 'سالن تخصصی بانوان، خدمات رنگ مو، کراتین و اکستنشن',
        address: 'تهران، ولیعصر، بالاتر از پارک ساعی',
        lat: 35.7315,
        lng: 51.3985,
        rating: 4.6,
        reviewCount: 89,
        isVerified: true,
        category: SalonCategory.female,
        ownerId: 'b_demo2',
        city: 'تهران',
        openTime: '10:00',
        closeTime: '20:00',
        phone: '02188002200',
      ),
      SalonModel(
        id: 'salon_demo3',
        name: 'آرایشگاه مدرن شیراز',
        description: 'ارائه خدمات آرایشی مردانه با جدیدترین متدهای روز دنیا',
        address: 'شیراز، قصرالدشت، خیابان کریم خان',
        lat: 29.5918,
        lng: 52.5836,
        rating: 4.5,
        reviewCount: 57,
        isVerified: false,
        category: SalonCategory.male,
        ownerId: 'b_demo1',
        city: 'شیراز',
        openTime: '09:00',
        closeTime: '22:00',
        phone: '07132003300',
      ),
      SalonModel(
        id: 'salon_demo4',
        name: 'استودیو یونیسکس اصفهان',
        description: 'استودیو زیبایی مختلط با بهترین امکانات و متخصص‌ترین تیم',
        address: 'اصفهان، چهارباغ عباسی، نبش خیابان هشت بهشت',
        lat: 32.6546,
        lng: 51.6680,
        rating: 4.7,
        reviewCount: 201,
        isVerified: true,
        category: SalonCategory.unisex,
        ownerId: 'b_demo1',
        city: 'اصفهان',
        openTime: '08:00',
        closeTime: '21:00',
        phone: '03132004400',
      ),
    ];
  }

  static void _initStylists() {
    stylists = [
      StylistModel(id: 'st_salon_demo1', salonId: 'salon_demo1', name: 'حسین نوری', specialty: 'آرایشگر', rating: 4.9),
      StylistModel(id: 'st_salon_demo2', salonId: 'salon_demo2', name: 'مریم صادقی', specialty: 'متخصص مو', rating: 4.7),
      StylistModel(id: 'st_salon_demo3', salonId: 'salon_demo3', name: 'رضا احمدی', specialty: 'آرایشگر', rating: 4.5),
      StylistModel(id: 'st_salon_demo4', salonId: 'salon_demo4', name: 'نیلوفر کریمی', specialty: 'استایلیست', rating: 4.8),
    ];
  }

  static void _initServices() {
    services = [
      const ServiceModel(id: 'svc_d1_1', salonId: 'salon_demo1', name: 'کوتاهی مو', durationMinutes: 30, price: 120000, category: 'hair'),
      const ServiceModel(id: 'svc_d1_2', salonId: 'salon_demo1', name: 'اصلاح ریش', durationMinutes: 20, price: 80000, category: 'beard'),
      const ServiceModel(id: 'svc_d1_3', salonId: 'salon_demo1', name: 'شامپو و سشوار', durationMinutes: 20, price: 60000, category: 'hair'),
      const ServiceModel(id: 'svc_d2_1', salonId: 'salon_demo2', name: 'رنگ مو', durationMinutes: 90, price: 450000, category: 'color'),
      const ServiceModel(id: 'svc_d2_2', salonId: 'salon_demo2', name: 'کوتاهی مو', durationMinutes: 45, price: 180000, category: 'hair'),
      const ServiceModel(id: 'svc_d2_3', salonId: 'salon_demo2', name: 'کراتین', durationMinutes: 120, price: 800000, category: 'treatment'),
      const ServiceModel(id: 'svc_d3_1', salonId: 'salon_demo3', name: 'کوتاهی مو', durationMinutes: 30, price: 100000, category: 'hair'),
      const ServiceModel(id: 'svc_d3_2', salonId: 'salon_demo3', name: 'پاکسازی صورت', durationMinutes: 40, price: 150000, category: 'skin'),
      const ServiceModel(id: 'svc_d4_1', salonId: 'salon_demo4', name: 'کوتاهی مو', durationMinutes: 40, price: 200000, category: 'hair'),
      const ServiceModel(id: 'svc_d4_2', salonId: 'salon_demo4', name: 'هایلایت', durationMinutes: 100, price: 600000, category: 'color'),
    ];
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
