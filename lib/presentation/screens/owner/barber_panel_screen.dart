import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/salon_model.dart';

class BarberPanelScreen extends StatefulWidget {
  const BarberPanelScreen({super.key});

  @override
  State<BarberPanelScreen> createState() => _BarberPanelScreenState();
}

class _BarberPanelScreenState extends State<BarberPanelScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();
    final barberName = user?.fullName ?? 'آرایشگر';

    final tabs = [
      _DashboardTab(barberName: barberName),
      const _AppointmentsTab(),
      const _SalonTab(),
      _ProfileTab(barberName: barberName),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.secondary),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.secondary),
            label: 'نوبت‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store, color: AppColors.secondary),
            label: 'سالن',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: AppColors.secondary),
            label: 'پروفایل',
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ──────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final String barberName;

  const _DashboardTab({required this.barberName});

  List<AppointmentModel> get _todayAppointments {
    final today = DateTime.now();
    return MockData.appointments
        .where((a) =>
            a.date.year == today.year &&
            a.date.month == today.month &&
            a.date.day == today.day &&
            a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get _todayRevenue =>
      _todayAppointments.fold(0, (sum, a) => sum + a.totalPrice);

  bool get _hasSalon => MockData.salons.any((s) => s.ownerId == StorageService.getUser()?.id);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayApts = _todayAppointments;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 52, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'سلام، $barberName 👋',
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PersianUtils.gregorianToJalali(today),
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick stats
                  Row(
                    children: [
                      _StatCard(
                        label: 'نوبت‌های امروز',
                        value: PersianUtils.toPersianDigits(todayApts.length.toString()),
                        icon: Icons.calendar_today,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'درآمد امروز',
                        value: PersianUtils.formatPriceShort(_todayRevenue),
                        icon: Icons.payments_outlined,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Salon registration prompt if no salon
                  if (!_hasSalon) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.store_outlined, size: 48, color: AppColors.secondary),
                          const SizedBox(height: 12),
                          const Text(
                            'هنوز سالنی ثبت نکرده‌اید',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'برای دریافت نوبت، ابتدا سالن خود را ثبت کنید',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed(Routes.barberRegister),
                            icon: const Icon(Icons.add_business),
                            label: const Text(
                              'ثبت سالن',
                              style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Today's appointments
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'نوبت‌های امروز',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (todayApts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text(
                            'امروز نوبتی ندارید',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...todayApts.map((a) => _AppointmentCard(appointment: a)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Appointments Tab ────────────────────────────────────────────────────────

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context) {
    final upcoming = MockData.appointments
        .where((a) =>
            a.date.isAfter(DateTime.now().subtract(const Duration(hours: 1))) &&
            a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) {
        final dateCmp = a.date.compareTo(b.date);
        if (dateCmp != 0) return dateCmp;
        return a.startTime.compareTo(b.startTime);
      });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('نوبت‌ها'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: upcoming.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'نوبت آینده‌ای ندارید',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              itemBuilder: (_, i) => _AppointmentCard(appointment: upcoming[i]),
            ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  PersianUtils.formatTime(appointment.startTime),
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  PersianUtils.toPersianDigits(appointment.date.day.toString()),
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.serviceNames.join('، '),
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.salonName,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              PersianUtils.formatTime(appointment.startTime),
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Salon Tab ──────────────────────────────────────────────────────────────

class _SalonTab extends StatelessWidget {
  const _SalonTab();

  SalonModel? get _barberSalon {
    final userId = StorageService.getUser()?.id;
    if (userId == null) return null;
    try {
      return MockData.salons.firstWhere((s) => s.ownerId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final salon = _barberSalon;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('سالن من'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (salon == null)
            TextButton(
              onPressed: () => Get.toNamed(Routes.barberRegister),
              child: const Text(
                'ثبت سالن',
                style: TextStyle(color: Colors.white, fontFamily: 'Vazirmatn'),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: salon == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_outlined, size: 72, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text(
                    'سالنی ثبت نشده است',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'برای شروع، سالن خود را ثبت کنید',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.barberRegister),
                    icon: const Icon(Icons.add_business),
                    label: const Text(
                      'ثبت سالن',
                      style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.store, color: Colors.white, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        salon.name,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        salon.categoryLabel,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoTile(icon: Icons.location_on_outlined, label: 'آدرس', value: salon.address),
                _InfoTile(icon: Icons.description_outlined, label: 'توضیحات', value: salon.description),
                _InfoTile(icon: Icons.star_outline, label: 'امتیاز', value: salon.rating.toStringAsFixed(1)),
              ],
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Tab ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final String barberName;

  const _ProfileTab({required this.barberName});

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('پروفایل'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: const Icon(Icons.person, size: 50, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              barberName,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'آرایشگر',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (user?.phone != null)
            _InfoTile(icon: Icons.phone_outlined, label: 'شماره موبایل', value: user!.phone),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await StorageService.clear();
              Get.offAllNamed('/splash');
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text(
              'خروج از حساب',
              style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
