import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/appointment_model.dart';

class OwnerPanelScreen extends StatefulWidget {
  const OwnerPanelScreen({super.key});

  @override
  State<OwnerPanelScreen> createState() => _OwnerPanelScreenState();
}

class _OwnerPanelScreenState extends State<OwnerPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _ownerSalonId = 's1'; // default for demo

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentModel> get _todayAppointments {
    final today = DateTime.now();
    return MockData.appointments.where((a) =>
        a.salonId == _ownerSalonId &&
        a.date.year == today.year &&
        a.date.month == today.month &&
        a.date.day == today.day &&
        a.status != AppointmentStatus.cancelled).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get _todayRevenue =>
      _todayAppointments.fold(0, (sum, a) => sum + a.totalPrice);

  int get _weekRevenue => MockData.appointments
      .where((a) =>
          a.salonId == _ownerSalonId &&
          a.date.isAfter(DateTime.now().subtract(const Duration(days: 7))) &&
          a.status != AppointmentStatus.cancelled)
      .fold(0, (sum, a) => sum + a.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'امروز'),
            Tab(text: 'هفته'),
            Tab(text: 'آمار'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodayTab(
            appointments: _todayAppointments,
            todayRevenue: _todayRevenue,
          ),
          _WeekTab(salonId: _ownerSalonId),
          _StatsTab(
            totalAppointments: MockData.appointments.where((a) => a.salonId == _ownerSalonId).length,
            weekRevenue: _weekRevenue,
            todayRevenue: _todayRevenue,
          ),
        ],
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final int todayRevenue;

  const _TodayTab({required this.appointments, required this.todayRevenue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              _QuickStat(
                label: 'نوبت‌های امروز',
                value: PersianUtils.toPersianDigits(appointments.length.toString()),
                icon: Icons.calendar_today,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _QuickStat(
                label: 'درآمد امروز',
                value: PersianUtils.formatPriceShort(todayRevenue),
                icon: Icons.payments,
                color: AppColors.success,
              ),
            ],
          ),
        ),
        Expanded(
          child: appointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'امروز نوبتی ندارید',
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
                  itemCount: appointments.length,
                  itemBuilder: (_, i) {
                    final a = appointments[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  PersianUtils.formatTime(a.startTime),
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  PersianUtils.formatTime(a.endTime),
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
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
                                  a.serviceNames.join('، '),
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (a.stylistName != null)
                                  Text(
                                    'آرایشگر: ${a.stylistName}',
                                    style: const TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            PersianUtils.formatPriceShort(a.totalPrice),
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WeekTab extends StatelessWidget {
  final String salonId;

  const _WeekTab({required this.salonId});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: days.map((day) {
        final dayAppointments = MockData.appointments.where((a) =>
            a.salonId == salonId &&
            a.date.year == day.year &&
            a.date.month == day.month &&
            a.date.day == day.day &&
            a.status != AppointmentStatus.cancelled).toList();

        final isToday = day.year == now.year &&
            day.month == now.month &&
            day.day == now.day;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday ? AppColors.secondary : AppColors.divider,
              width: isToday ? 2 : 1,
            ),
          ),
          child: ExpansionTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isToday ? AppColors.secondary : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    PersianUtils.toPersianDigits(day.day.toString()),
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isToday ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              PersianUtils.weekDayName(day),
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${PersianUtils.toPersianDigits(dayAppointments.length.toString())} نوبت',
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary),
            ),
            children: dayAppointments.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'نوبتی ندارید',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ]
                : dayAppointments
                    .map((a) => ListTile(
                          dense: true,
                          leading: Text(
                            PersianUtils.formatTime(a.startTime),
                            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12),
                          ),
                          title: Text(
                            a.serviceNames.join('، '),
                            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13),
                          ),
                          trailing: Text(
                            PersianUtils.formatPriceShort(a.totalPrice),
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                        ))
                    .toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final int totalAppointments;
  final int weekRevenue;
  final int todayRevenue;

  const _StatsTab({
    required this.totalAppointments,
    required this.weekRevenue,
    required this.todayRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(
          title: 'درآمد امروز',
          value: PersianUtils.formatPrice(todayRevenue),
          icon: Icons.today,
          color: AppColors.success,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'درآمد این هفته',
          value: PersianUtils.formatPrice(weekRevenue),
          icon: Icons.date_range,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'کل نوبت‌ها',
          value: PersianUtils.toPersianDigits(totalAppointments.toString()),
          icon: Icons.calendar_month,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        const Text(
          'وضعیت روزهای کاری',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(7, (i) {
          final days = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Text(
                  days[i],
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  i == 6 ? '۱۰:۰۰ - ۱۸:۰۰' : '۰۹:۰۰ - ۲۱:۰۰',
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.success,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 16,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
