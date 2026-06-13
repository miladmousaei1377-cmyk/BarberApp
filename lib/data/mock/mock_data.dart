import '../models/salon_model.dart';
import '../models/stylist_model.dart';
import '../models/service_model.dart';
import '../models/review_model.dart';
import '../models/appointment_model.dart';
import '../models/working_hours_model.dart';

class MockData {
  static List<SalonModel> salons = [];
  static List<StylistModel> stylists = [];
  static List<ServiceModel> services = [];
  static List<ReviewModel> reviews = [];
  static List<AppointmentModel> appointments = [];
  static List<WorkingHoursModel> workingHours = [];

  static void init() {
    _initSalons();
    _initStylists();
    _initServices();
    _initWorkingHours();
    _initReviews();
    _initAppointments();
  }

  static void _initSalons() {
    salons = [
      const SalonModel(
        id: 's1',
        name: 'آرایشگاه مدرن',
        description:
            'آرایشگاه مدرن با بهترین متخصصین آرایش مردانه، ارائه‌دهنده خدمات حرفه‌ای کوتاهی مو، اصلاح ریش و انواع رنگ‌بندی با محصولات اصل',
        address: 'خیابان ولیعصر، نرسیده به چهارراه ولیعصر',
        lat: 35.7448,
        lng: 51.4100,
        rating: 4.8,
        reviewCount: 124,
        isVerified: true,
        category: SalonCategory.male,
        ownerId: 'u_owner1',
        images: [],
      ),
      const SalonModel(
        id: 's2',
        name: 'سالن زیبایی لاله',
        description:
            'سالن تخصصی خدمات زیبایی بانوان با محیطی آرام و دلنشین. کوتاهی مو، رنگ، کراتین و انواع مدل‌های مدرن توسط متخصصین مجرب',
        address: 'خیابان انقلاب، روبروی دانشگاه تهران',
        lat: 35.7001,
        lng: 51.3877,
        rating: 4.6,
        reviewCount: 89,
        isVerified: true,
        category: SalonCategory.female,
        ownerId: 'u_owner2',
        images: [],
      ),
      const SalonModel(
        id: 's3',
        name: 'باربر شاپ کلاسیک',
        description:
            'تجربه‌ای متفاوت از آرایش سنتی مردانه. استفاده از ابزار کلاسیک و تکنیک‌های قدیمی با کیفیتی بی‌نظیر',
        address: 'میدان آزادی، ابتدای خیابان آزادی',
        lat: 35.6996,
        lng: 51.3376,
        rating: 4.5,
        reviewCount: 67,
        isVerified: false,
        category: SalonCategory.male,
        ownerId: 'u_owner3',
        images: [],
      ),
      const SalonModel(
        id: 's4',
        name: 'سالن آریا',
        description:
            'سالن یونیسکس با امکانات مدرن و تیمی از متخصصین با تجربه. مناسب برای خانم‌ها و آقایان. خدمات متنوع با کیفیت بالا',
        address: 'خیابان شریعتی، نزدیک پل صدر',
        lat: 35.7591,
        lng: 51.4339,
        rating: 4.7,
        reviewCount: 156,
        isVerified: true,
        category: SalonCategory.unisex,
        ownerId: 'u_owner4',
        images: [],
      ),
      const SalonModel(
        id: 's5',
        name: 'آرایشگاه رویال',
        description:
            'لوکس‌ترین آرایشگاه مردانه در شمال تهران. با استفاده از بهترین محصولات و ارائه خدمات VIP به مشتریان گرامی',
        address: 'نیاوران، خیابان باهنر',
        lat: 35.8108,
        lng: 51.4638,
        rating: 4.9,
        reviewCount: 203,
        isVerified: true,
        category: SalonCategory.male,
        ownerId: 'u_owner5',
        images: [],
      ),
    ];
  }

  static void _initStylists() {
    stylists = [
      // Salon 1 - آرایشگاه مدرن
      const StylistModel(
        id: 'st1',
        salonId: 's1',
        name: 'علی محمدی',
        specialty: 'کوتاهی و رنگ مو',
        rating: 4.9,
      ),
      const StylistModel(
        id: 'st2',
        salonId: 's1',
        name: 'رضا احمدی',
        specialty: 'اصلاح ریش و مو',
        rating: 4.7,
      ),
      // Salon 2 - سالن زیبایی لاله
      const StylistModel(
        id: 'st3',
        salonId: 's2',
        name: 'سارا کریمی',
        specialty: 'کراتین و رنگ مو',
        rating: 4.8,
      ),
      const StylistModel(
        id: 'st4',
        salonId: 's2',
        name: 'مریم رضایی',
        specialty: 'کوتاهی و مدل مو',
        rating: 4.6,
      ),
      // Salon 3 - باربر شاپ کلاسیک
      const StylistModel(
        id: 'st5',
        salonId: 's3',
        name: 'حسین نوری',
        specialty: 'آرایش کلاسیک',
        rating: 4.5,
      ),
      // Salon 4 - سالن آریا
      const StylistModel(
        id: 'st6',
        salonId: 's4',
        name: 'نادر قاسمی',
        specialty: 'کوتاهی مدرن',
        rating: 4.7,
      ),
      const StylistModel(
        id: 'st7',
        salonId: 's4',
        name: 'فاطمه حسینی',
        specialty: 'رنگ و هایلایت',
        rating: 4.8,
      ),
      // Salon 5 - آرایشگاه رویال
      const StylistModel(
        id: 'st8',
        salonId: 's5',
        name: 'محمد صادقی',
        specialty: 'کوتاهی VIP',
        rating: 5.0,
      ),
      const StylistModel(
        id: 'st9',
        salonId: 's5',
        name: 'امیر حسین زاده',
        specialty: 'اصلاح و مراقبت ریش',
        rating: 4.9,
      ),
    ];
  }

  static void _initServices() {
    services = [
      // Salon 1
      const ServiceModel(id: 'sv1', salonId: 's1', name: 'کوتاهی مو', durationMinutes: 30, price: 120000, category: 'hair'),
      const ServiceModel(id: 'sv2', salonId: 's1', name: 'اصلاح ریش', durationMinutes: 20, price: 60000, category: 'beard'),
      const ServiceModel(id: 'sv3', salonId: 's1', name: 'رنگ مو', durationMinutes: 90, price: 280000, category: 'color'),
      const ServiceModel(id: 'sv4', salonId: 's1', name: 'ماسک مو', durationMinutes: 30, price: 120000, category: 'care'),
      const ServiceModel(id: 'sv5', salonId: 's1', name: 'اصلاح ابرو', durationMinutes: 15, price: 30000, category: 'eyebrow'),
      const ServiceModel(id: 'sv6', salonId: 's1', name: 'کوتاهی و اصلاح', durationMinutes: 45, price: 170000, category: 'combo'),

      // Salon 2
      const ServiceModel(id: 'sv7', salonId: 's2', name: 'کوتاهی مو', durationMinutes: 45, price: 150000, category: 'hair'),
      const ServiceModel(id: 'sv8', salonId: 's2', name: 'رنگ مو', durationMinutes: 120, price: 450000, category: 'color'),
      const ServiceModel(id: 'sv9', salonId: 's2', name: 'کراتین', durationMinutes: 180, price: 600000, category: 'treatment'),
      const ServiceModel(id: 'sv10', salonId: 's2', name: 'ماسک مو', durationMinutes: 30, price: 120000, category: 'care'),
      const ServiceModel(id: 'sv11', salonId: 's2', name: 'اصلاح ابرو', durationMinutes: 15, price: 30000, category: 'eyebrow'),
      const ServiceModel(id: 'sv12', salonId: 's2', name: 'هایلایت', durationMinutes: 150, price: 500000, category: 'color'),

      // Salon 3
      const ServiceModel(id: 'sv13', salonId: 's3', name: 'کوتاهی مو', durationMinutes: 30, price: 80000, category: 'hair'),
      const ServiceModel(id: 'sv14', salonId: 's3', name: 'اصلاح ریش', durationMinutes: 20, price: 50000, category: 'beard'),
      const ServiceModel(id: 'sv15', salonId: 's3', name: 'اصلاح کلاسیک', durationMinutes: 40, price: 120000, category: 'classic'),
      const ServiceModel(id: 'sv16', salonId: 's3', name: 'اصلاح ابرو', durationMinutes: 15, price: 30000, category: 'eyebrow'),

      // Salon 4
      const ServiceModel(id: 'sv17', salonId: 's4', name: 'کوتاهی مو', durationMinutes: 40, price: 130000, category: 'hair'),
      const ServiceModel(id: 'sv18', salonId: 's4', name: 'اصلاح ریش', durationMinutes: 20, price: 70000, category: 'beard'),
      const ServiceModel(id: 'sv19', salonId: 's4', name: 'رنگ مو', durationMinutes: 100, price: 350000, category: 'color'),
      const ServiceModel(id: 'sv20', salonId: 's4', name: 'کراتین', durationMinutes: 150, price: 500000, category: 'treatment'),
      const ServiceModel(id: 'sv21', salonId: 's4', name: 'ماسک مو', durationMinutes: 30, price: 120000, category: 'care'),
      const ServiceModel(id: 'sv22', salonId: 's4', name: 'اصلاح ابرو', durationMinutes: 15, price: 30000, category: 'eyebrow'),

      // Salon 5
      const ServiceModel(id: 'sv23', salonId: 's5', name: 'کوتاهی VIP', durationMinutes: 45, price: 150000, category: 'hair'),
      const ServiceModel(id: 'sv24', salonId: 's5', name: 'اصلاح ریش VIP', durationMinutes: 30, price: 80000, category: 'beard'),
      const ServiceModel(id: 'sv25', salonId: 's5', name: 'رنگ مو', durationMinutes: 90, price: 380000, category: 'color'),
      const ServiceModel(id: 'sv26', salonId: 's5', name: 'کراتین', durationMinutes: 180, price: 580000, category: 'treatment'),
      const ServiceModel(id: 'sv27', salonId: 's5', name: 'ماسک و مراقبت', durationMinutes: 60, price: 200000, category: 'care'),
      const ServiceModel(id: 'sv28', salonId: 's5', name: 'پکیج کامل', durationMinutes: 90, price: 300000, category: 'combo'),
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
    reviews = [
      ReviewModel(
        id: 'r1',
        userId: 'u1',
        userName: 'محمد رضایی',
        salonId: 's1',
        rating: 5,
        comment: 'عالی بود! آقای محمدی خیلی حرفه‌ای کار می‌کنن. حتماً دوباره میام.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ReviewModel(
        id: 'r2',
        userId: 'u2',
        userName: 'امیر حسین کرمی',
        salonId: 's1',
        rating: 5,
        comment: 'بهترین آرایشگاه تهران! محیط تمیز، پرسنل مؤدب و کار با کیفیت.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ReviewModel(
        id: 'r3',
        userId: 'u3',
        userName: 'علی نجفی',
        salonId: 's1',
        rating: 4,
        comment: 'خدمات خوب بود ولی کمی منتظر موندم. در کل راضی بودم.',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      ReviewModel(
        id: 'r4',
        userId: 'u4',
        userName: 'فاطمه احمدی',
        salonId: 's2',
        rating: 5,
        comment: 'خانم کریمی استاد کراتین هستن! موهام فوق‌العاده شد.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: 'r5',
        userId: 'u5',
        userName: 'زهرا محمدی',
        salonId: 's2',
        rating: 4,
        comment: 'سالن تمیز و محیط آرامش‌بخش. رنگم خوب دراومد.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ReviewModel(
        id: 'r6',
        userId: 'u6',
        userName: 'رضا قاسمی',
        salonId: 's5',
        rating: 5,
        comment: 'واقعاً رویال! خدمات VIP با قیمت منصفانه. آقای صادقی بهترین هستن.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReviewModel(
        id: 'r7',
        userId: 'u7',
        userName: 'حسین مرادی',
        salonId: 's5',
        rating: 5,
        comment: 'اگه دنبال تجربه لاکچری هستید، اینجا بیاید. قطعاً ارزشش رو داره.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
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
    return appointment;
  }

  static bool cancelAppointment(String appointmentId) {
    final idx = appointments.indexWhere((a) => a.id == appointmentId);
    if (idx == -1) return false;
    appointments[idx] = appointments[idx].copyWith(status: AppointmentStatus.cancelled);
    return true;
  }
}
