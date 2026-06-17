import 'package:get/get.dart';
import '../data/models/salon_model.dart';
import '../data/models/service_model.dart';
import '../data/models/stylist_model.dart';
import '../data/models/appointment_model.dart';
import '../data/mock/mock_data.dart';
import '../core/storage/storage_service.dart';

class WorkingDay {
  bool isOff;
  String start;
  String end;

  WorkingDay({required this.isOff, required this.start, required this.end});
}

class OwnerController extends GetxController {
  static OwnerController get to => Get.find();

  final salon = Rxn<SalonModel>();
  final services = <ServiceModel>[].obs;
  final appointments = <AppointmentModel>[].obs;
  // index 0=شنبه … 6=جمعه
  final workingHours = <WorkingDay>[].obs;

  @override
  void onInit() {
    super.onInit();
    workingHours.value = List.generate(
      7,
      (i) => WorkingDay(
        isOff: i == 6,
        start: i == 6 ? '10:00' : '09:00',
        end: i == 6 ? '18:00' : '21:00',
      ),
    );
    loadData();
  }

  void loadData() {
    final userId = StorageService.getUser()?.id;
    if (userId == null) return;
    try {
      salon.value = MockData.salons.firstWhere((s) => s.ownerId == userId);
      _loadSalonData();
    } catch (_) {
      salon.value = null;
    }
  }

  void _loadSalonData() {
    final salonId = salon.value?.id;
    if (salonId == null) return;
    services.value = MockData.services.where((s) => s.salonId == salonId).toList();
    appointments.value = MockData.appointments.where((a) => a.salonId == salonId).toList();
  }

  void registerSalon(SalonModel s) {
    MockData.salons.add(s);
    salon.value = s;
    services.clear();
    appointments.clear();
    // Auto-add owner as a stylist so they appear in customer-facing stylist list
    final user = StorageService.getUser();
    if (user != null) {
      MockData.stylists.add(StylistModel(
        id: 'st_${s.id}',
        salonId: s.id,
        name: user.fullName,
        specialty: 'آرایشگر',
        rating: 5.0,
      ));
    }
  }

  void updateSalon(SalonModel updated) {
    final idx = MockData.salons.indexWhere((s) => s.id == updated.id);
    if (idx != -1) MockData.salons[idx] = updated;
    salon.value = updated;
  }

  void addService(ServiceModel s) {
    MockData.services.add(s);
    services.add(s);
  }

  void updateService(ServiceModel updated) {
    final mIdx = MockData.services.indexWhere((s) => s.id == updated.id);
    if (mIdx != -1) MockData.services[mIdx] = updated;
    final lIdx = services.indexWhere((s) => s.id == updated.id);
    if (lIdx != -1) services[lIdx] = updated;
  }

  void deleteService(String serviceId) {
    MockData.services.removeWhere((s) => s.id == serviceId);
    services.removeWhere((s) => s.id == serviceId);
  }

  void updateWorkingDay(int dayIdx, WorkingDay updated) {
    workingHours[dayIdx] = updated;
    workingHours.refresh();
  }

  void confirmAppointment(String id) => _setStatus(id, AppointmentStatus.confirmed);
  void completeAppointment(String id) => _setStatus(id, AppointmentStatus.done);
  void cancelAppointmentByOwner(String id) => _setStatus(id, AppointmentStatus.cancelled);

  void _setStatus(String id, AppointmentStatus status) {
    final mIdx = MockData.appointments.indexWhere((a) => a.id == id);
    if (mIdx != -1) {
      MockData.appointments[mIdx] = MockData.appointments[mIdx].copyWith(status: status);
    }
    final lIdx = appointments.indexWhere((a) => a.id == id);
    if (lIdx != -1) {
      appointments[lIdx] = appointments[lIdx].copyWith(status: status);
    }
  }

  List<AppointmentModel> get todayAppointments {
    final t = DateTime.now();
    return appointments
        .where((a) =>
            a.date.year == t.year &&
            a.date.month == t.month &&
            a.date.day == t.day &&
            a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<AppointmentModel> appointmentsForDate(DateTime date) {
    return appointments
        .where((a) =>
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get todayRevenue => todayAppointments
      .where((a) => a.status == AppointmentStatus.done)
      .fold(0, (s, a) => s + a.totalPrice);

  int get weekRevenue {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    return appointments
        .where((a) =>
            !a.date.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
            a.status == AppointmentStatus.done)
        .fold(0, (s, a) => s + a.totalPrice);
  }

  int get monthRevenue {
    final now = DateTime.now();
    return appointments
        .where((a) =>
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.status == AppointmentStatus.done)
        .fold(0, (s, a) => s + a.totalPrice);
  }

  int get monthAppointmentCount {
    final now = DateTime.now();
    return appointments
        .where((a) =>
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.status != AppointmentStatus.cancelled)
        .length;
  }

  double get cancelRate {
    if (appointments.isEmpty) return 0.0;
    final cancelled = appointments.where((a) => a.status == AppointmentStatus.cancelled).length;
    return cancelled / appointments.length * 100;
  }

  List<int> get last7DaysRevenue {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return appointments
          .where((a) =>
              a.date.year == day.year &&
              a.date.month == day.month &&
              a.date.day == day.day &&
              a.status == AppointmentStatus.done)
          .fold(0, (s, a) => s + a.totalPrice);
    });
  }
}
