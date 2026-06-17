import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../controllers/owner_controller.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/salon_model.dart';

// ── Panel colours ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF0F3460);
const _kAccent  = Color(0xFF533483);
const _kSuccess = Color(0xFF28A745);
const _kWarning = Color(0xFFFFC107);
const _kDanger  = Color(0xFFDC3545);
const _kBg      = Color(0xFFF4F6FA);
const _kSurface = Colors.white;

const _dayNames = ['شنبه','یکشنبه','دوشنبه','سه‌شنبه','چهارشنبه','پنجشنبه','جمعه'];

const _kIranCities = [
  'تهران', 'مشهد', 'اصفهان', 'کرج', 'شیراز', 'تبریز', 'اهواز',
  'قم', 'کرمانشاه', 'ارومیه', 'رشت', 'زاهدان', 'همدان', 'کرمان',
  'یزد', 'اردبیل', 'بندر عباس', 'اراک', 'قزوین', 'سنندج',
  'سمنان', 'گرگان', 'ساری', 'زنجان', 'بیرجند', 'خرم‌آباد',
];

// ════════════════════════════════════════════════════════════════════════════
// Main screen  —  tabs: داشبورد / نوبت‌ها / سالن / آمار / پروفایل
// ════════════════════════════════════════════════════════════════════════════

class BarberPanelScreen extends StatefulWidget {
  const BarberPanelScreen({super.key});
  @override
  State<BarberPanelScreen> createState() => _BarberPanelScreenState();
}

class _BarberPanelScreenState extends State<BarberPanelScreen> {
  final _tabNotifier = ValueNotifier<int>(0);
  final _aptTabKey = GlobalKey<_AppointmentsTabState>();

  @override
  void initState() {
    super.initState();
    Get.put(OwnerController());
  }

  @override
  void dispose() {
    _tabNotifier.dispose();
    Get.delete<OwnerController>(force: true);
    super.dispose();
  }

  void _goToAptsAllTab() {
    _tabNotifier.value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aptTabKey.currentState?.switchToTab(2);
    });
  }

  Future<void> _onWillPop(BuildContext context) async {
    if (_tabNotifier.value != 0) {
      _tabNotifier.value = 0;
      return;
    }
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('خروج از برنامه', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
          content: const Text('آیا می‌خواهید از برنامه خارج شوید؟', style: TextStyle(fontFamily: 'Vazirmatn')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('خیر', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: _kDanger),
              child: const Text('خروج', style: TextStyle(fontFamily: 'Vazirmatn')),
            ),
          ],
        ),
      ),
    );
    if (exit == true) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _onWillPop(context),
      child: ValueListenableBuilder<int>(
        valueListenable: _tabNotifier,
        builder: (_, tab, __) => Scaffold(
          backgroundColor: _kBg,
          body: IndexedStack(
            index: tab,
            children: [
              _DashboardTab(
                onNavigateToTab: (i) => _tabNotifier.value = i,
                onNavigateToAptsAllTab: _goToAptsAllTab,
              ),
              _AppointmentsTab(key: _aptTabKey),
              const _SalonManagementTab(),
              const _StatsTab(),
              const _OwnerProfileTab(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => _tabNotifier.value = i,
            backgroundColor: _kSurface,
            indicatorColor: _kPrimary.withOpacity(0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: _kPrimary),
                label: 'داشبورد',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month, color: _kPrimary),
                label: 'نوبت‌ها',
              ),
              NavigationDestination(
                icon: Icon(Icons.store_outlined),
                selectedIcon: Icon(Icons.store, color: _kPrimary),
                label: 'آرایشگاه',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart, color: _kPrimary),
                label: 'آمار',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: _kPrimary),
                label: 'پروفایل',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 1 — Dashboard
// ════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatefulWidget {
  final void Function(int) onNavigateToTab;
  final VoidCallback? onNavigateToAptsAllTab;
  const _DashboardTab({required this.onNavigateToTab, this.onNavigateToAptsAllTab});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = StorageService.selectedCity;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!StorageService.hasCitySelected && mounted) {
        _showCitySelector(firstTime: true);
      }
    });
  }

  void _showCitySelector({bool firstTime = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final searchCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setS) {
            final query = searchCtrl.text.trim();
            final filtered = query.isEmpty
                ? _kIranCities
                : _kIranCities.where((c) => c.contains(query)).toList();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_city, color: _kPrimary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              firstTime ? 'شهر خود را انتخاب کنید' : 'تغییر شهر',
                              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: _kPrimary),
                            ),
                          ],
                        ),
                        if (firstTime) ...[
                          const SizedBox(height: 4),
                          const Text('برای نمایش آرایشگاه‌های شهر خود', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.grey)),
                        ],
                        const SizedBox(height: 12),
                        TextField(
                          controller: searchCtrl,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'جستجوی شهر...',
                            hintStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onChanged: (_) => setS(() {}),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final city = filtered[i];
                        final isSelected = city == _selectedCity;
                        return ListTile(
                          title: Text(city, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, color: isSelected ? _kPrimary : Colors.black87)),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: _kPrimary, size: 20) : null,
                          onTap: () async {
                            await StorageService.setSelectedCity(city);
                            if (mounted) {
                              setState(() => _selectedCity = city);
                              Navigator.pop(ctx);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = OwnerController.to;
    final user = StorageService.getUser();
    final name = user?.fullName ?? 'آرایشگر';

    return Scaffold(
      backgroundColor: _kBg,
      body: Obx(() {
        final hasSalon = ctrl.salon.value != null;
        final todayApts = ctrl.todayAppointments;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: _kPrimary,
              actions: [
                GestureDetector(
                  onTap: () => _showCitySelector(),
                  child: Container(
                    margin: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_city, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _selectedCity ?? 'انتخاب شهر',
                          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kPrimary, _kAccent],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'سلام، $name 👋',
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PersianUtils.gregorianToJalali(DateTime.now()),
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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      _MiniStat(
                        label: 'نوبت‌های امروز',
                        value: PersianUtils.toPersianDigits(todayApts.length.toString()),
                        icon: Icons.calendar_today,
                        color: _kAccent,
                        onTap: () => widget.onNavigateToTab(1),
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        label: 'نوبت‌های هفتگی',
                        value: PersianUtils.toPersianDigits(ctrl.weekAppointmentCount.toString()),
                        icon: Icons.date_range_outlined,
                        color: _kSuccess,
                        onTap: () => widget.onNavigateToTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'نوبت‌های ماهانه',
                        value: PersianUtils.toPersianDigits(ctrl.monthAppointmentCount.toString()),
                        icon: Icons.bar_chart_outlined,
                        color: _kPrimary,
                        onTap: () => widget.onNavigateToTab(3),
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        label: 'نوبت‌های ماه',
                        value: PersianUtils.toPersianDigits(ctrl.monthAppointmentCount.toString()),
                        icon: Icons.people_outline,
                        color: _kWarning,
                        onTap: widget.onNavigateToAptsAllTab ?? () => widget.onNavigateToTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!hasSalon) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kPrimary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.store_outlined, size: 52, color: _kPrimary),
                          const SizedBox(height: 12),
                          const Text(
                            'هنوز آرایشگاهی ثبت نکرده‌اید',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'برای دریافت نوبت، ابتدا آرایشگاه خود را ثبت کنید',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed(Routes.barberRegister),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.add_business),
                            label: const Text('ثبت آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _SectionHeader(title: 'نوبت‌های امروز', icon: Icons.schedule),
                  const SizedBox(height: 8),
                  if (todayApts.isEmpty)
                    const _EmptyState(message: 'امروز نوبتی ندارید', icon: Icons.calendar_today_outlined)
                  else
                    ...todayApts.map((a) => _AptCard(apt: a, showActions: true)),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 2 — Appointments
// ════════════════════════════════════════════════════════════════════════════

class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab({super.key});
  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void switchToTab(int index) {
    if (_tabCtrl.index != index) _tabCtrl.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: _kPrimary,
        title: const Text('نوبت‌ها', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, color: _kPrimary)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: _kPrimary,
          labelStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
          labelColor: _kPrimary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'امروز'), Tab(text: 'هفتگی'), Tab(text: 'همه')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _TodayApts(),
          _WeeklyApts(),
          _AllApts(),
        ],
      ),
    );
  }
}

class _TodayApts extends StatelessWidget {
  const _TodayApts();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final apts = OwnerController.to.todayAppointments;
      if (apts.isEmpty) return const _EmptyState(message: 'امروز نوبتی ندارید', icon: Icons.calendar_today_outlined);
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: apts.length,
        itemBuilder: (_, i) {
          final apt = apts[i];
          return Dismissible(
            key: Key(apt.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: _kDanger, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            confirmDismiss: (_) => showDialog<bool>(
              context: context,
              builder: (ctx) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('حذف نوبت', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                  content: const Text('این نوبت از سیستم حذف می‌شود. آیا مطمئن هستید؟', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey))),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: _kDanger, foregroundColor: Colors.white),
                      child: const Text('حذف', style: TextStyle(fontFamily: 'Vazirmatn')),
                    ),
                  ],
                ),
              ),
            ),
            onDismissed: (_) {
              OwnerController.to.deleteAppointment(apt.id);
              Get.snackbar('حذف شد', 'نوبت از سیستم حذف شد', backgroundColor: _kDanger, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            },
            child: _AptCard(apt: apt, showActions: true),
          );
        },
      );
    });
  }
}

class _WeeklyApts extends StatefulWidget {
  const _WeeklyApts();
  @override
  State<_WeeklyApts> createState() => _WeeklyAptsState();
}

class _WeeklyAptsState extends State<_WeeklyApts> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final week = List.generate(7, (i) => DateTime.now().subtract(Duration(days: 3 - i)));
    return Obx(() {
      final ctrl = OwnerController.to;
      final dayApts = ctrl.appointmentsForDate(_selected);
      return Column(
        children: [
          Container(
            color: _kSurface,
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: week.length,
              itemBuilder: (_, i) {
                final day = week[i];
                final count = ctrl.appointmentsForDate(day).length;
                final isSelected = _selected.year == day.year && _selected.month == day.month && _selected.day == day.day;
                return GestureDetector(
                  onTap: () => setState(() => _selected = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? _kPrimary : _kBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          PersianUtils.weekDayName(day).substring(0, 2),
                          style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: isSelected ? Colors.white70 : Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PersianUtils.toPersianDigits(day.day.toString()),
                          style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : _kPrimary),
                        ),
                        if (count > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.3) : _kAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              PersianUtils.toPersianDigits(count.toString()),
                              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: dayApts.isEmpty
                ? const _EmptyState(message: 'این روز نوبتی ندارید', icon: Icons.event_available_outlined)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayApts.length,
                    itemBuilder: (_, i) {
                      final apt = dayApts[i];
                      return Dismissible(
                        key: Key(apt.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(color: _kDanger, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (_) => showDialog<bool>(
                          context: context,
                          builder: (ctx) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('حذف نوبت', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                              content: const Text('این نوبت از سیستم حذف می‌شود. آیا مطمئن هستید؟', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey))),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: _kDanger, foregroundColor: Colors.white),
                                  child: const Text('حذف', style: TextStyle(fontFamily: 'Vazirmatn')),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onDismissed: (_) {
                          OwnerController.to.deleteAppointment(apt.id);
                          Get.snackbar('حذف شد', 'نوبت از سیستم حذف شد', backgroundColor: _kDanger, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                        },
                        child: _AptCard(apt: apt, showActions: true),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}

class _AllApts extends StatefulWidget {
  const _AllApts();
  @override
  State<_AllApts> createState() => _AllAptsState();
}

class _AllAptsState extends State<_AllApts> {
  AppointmentStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var apts = OwnerController.to.appointments.toList();
      if (_filter != null) apts = apts.where((a) => a.status == _filter).toList();
      apts.sort((a, b) {
        final d = b.date.compareTo(a.date);
        return d != 0 ? d : b.startTime.compareTo(a.startTime);
      });
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(label: 'همه', isSelected: _filter == null, onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterChip(label: 'در انتظار', isSelected: _filter == AppointmentStatus.pending, color: _kWarning, onTap: () => setState(() => _filter = AppointmentStatus.pending)),
                const SizedBox(width: 8),
                _FilterChip(label: 'تأیید شده', isSelected: _filter == AppointmentStatus.confirmed, color: _kSuccess, onTap: () => setState(() => _filter = AppointmentStatus.confirmed)),
                const SizedBox(width: 8),
                _FilterChip(label: 'انجام شده', isSelected: _filter == AppointmentStatus.done, color: _kPrimary, onTap: () => setState(() => _filter = AppointmentStatus.done)),
                const SizedBox(width: 8),
                _FilterChip(label: 'لغو شده', isSelected: _filter == AppointmentStatus.cancelled, color: _kDanger, onTap: () => setState(() => _filter = AppointmentStatus.cancelled)),
              ],
            ),
          ),
          Expanded(
            child: apts.isEmpty
                ? const _EmptyState(message: 'نوبتی یافت نشد', icon: Icons.search_off_outlined)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: apts.length,
                    itemBuilder: (_, i) {
                      final apt = apts[i];
                      return Dismissible(
                        key: Key(apt.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(color: _kDanger, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (_) => showDialog<bool>(
                          context: context,
                          builder: (ctx) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('حذف نوبت', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                              content: const Text('این نوبت از سیستم حذف می‌شود. آیا مطمئن هستید؟', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey))),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: _kDanger, foregroundColor: Colors.white),
                                  child: const Text('حذف', style: TextStyle(fontFamily: 'Vazirmatn')),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onDismissed: (_) {
                          OwnerController.to.deleteAppointment(apt.id);
                          Get.snackbar('حذف شد', 'نوبت از سیستم حذف شد', backgroundColor: _kDanger, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                        },
                        child: _AptCard(apt: apt, showActions: true),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 3 — Salon Management  (اطلاعات | خدمات)
// ════════════════════════════════════════════════════════════════════════════

class _SalonManagementTab extends StatefulWidget {
  const _SalonManagementTab();
  @override
  State<_SalonManagementTab> createState() => _SalonManagementTabState();
}

class _SalonManagementTabState extends State<_SalonManagementTab> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabCtrl.removeListener(_onTabChange);
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onTabChange() => setState(() {});

  void _showServiceSheet(BuildContext context, {ServiceModel? editing}) {
    final ctrl = OwnerController.to;
    final salon = ctrl.salon.value;
    if (salon == null) {
      Get.snackbar('توجه', 'ابتدا آرایشگاه خود را ثبت کنید', backgroundColor: _kWarning, colorText: Colors.black);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceSheet(editing: editing, salonId: salon.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onServicesTab = _tabCtrl.index == 1;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
        actions: [
          if (onServicesTab)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showServiceSheet(context),
            ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'اطلاعات'), Tab(text: 'خدمات')],
        ),
      ),
      floatingActionButton: onServicesTab
          ? FloatingActionButton.extended(
              onPressed: () => _showServiceSheet(context),
              backgroundColor: _kPrimary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('خدمت جدید', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _SalonInfoSubTab(onAddServicesRequested: () => _tabCtrl.animateTo(1)),
          _ServicesSubTab(onShowSheet: _showServiceSheet),
        ],
      ),
    );
  }
}

// ── Sub-tab: Salon Info ───────────────────────────────────────────────────────

class _SalonInfoSubTab extends StatelessWidget {
  const _SalonInfoSubTab({this.onAddServicesRequested});
  final VoidCallback? onAddServicesRequested;

  void _showEditSalonSheet(BuildContext context, SalonModel salon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSalonSheet(salon: salon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = OwnerController.to;
      final salon = ctrl.salon.value;

      if (salon == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_outlined, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('آرایشگاهی ثبت نشده است', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('برای شروع، آرایشگاه خود را ثبت کنید', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.toNamed(Routes.barberRegister);
                  if (result == 'addServices') onAddServicesRequested?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_business),
                label: const Text('ثبت آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kPrimary, _kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(salon.name, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(salon.categoryLabel, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
                Switch(
                  value: salon.isActive,
                  onChanged: (v) => ctrl.updateSalon(salon.copyWith(isActive: v)),
                  activeColor: _kSuccess,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.edit_outlined,
            title: 'ویرایش اطلاعات آرایشگاه',
            subtitle: salon.address,
            onTap: () => _showEditSalonSheet(context, salon),
          ),
          if (salon.phone != null && salon.phone!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: _kPrimary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('شماره تلفن', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(salon.phone!, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (salon.lat != 0.0 && salon.lng != 0.0) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('موقعیت مکانی', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.teal)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(salon.lat, salon.lng),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.barberbook.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(salon.lat, salon.lng),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (salon.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionHeader(title: 'تصاویر آرایشگاه', icon: Icons.photo_library_outlined),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: salon.images.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(salon.images[i]),
                      width: 130,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 130,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SectionHeader(title: 'ساعت کاری', icon: Icons.schedule),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              children: List.generate(7, (i) {
                final day = ctrl.workingHours[i];
                return _WorkingDayRow(
                  dayName: _dayNames[i],
                  isOff: day.isOff,
                  start: day.start,
                  end: day.end,
                  isLast: i == 6,
                  onToggle: (v) => ctrl.updateWorkingDay(i, WorkingDay(isOff: !v, start: day.start, end: day.end)),
                  onTimeTap: (isStart) async {
                    final current = isStart ? day.start : day.end;
                    final parts = current.split(':');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                      builder: (ctx, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
                    );
                    if (picked != null) {
                      final t = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      ctrl.updateWorkingDay(i, WorkingDay(
                        isOff: day.isOff,
                        start: isStart ? t : day.start,
                        end: isStart ? day.end : t,
                      ));
                    }
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}

// ── Sub-tab: Services ─────────────────────────────────────────────────────────

class _ServicesSubTab extends StatelessWidget {
  final void Function(BuildContext, {ServiceModel? editing}) onShowSheet;
  const _ServicesSubTab({required this.onShowSheet});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = OwnerController.to;
      if (ctrl.salon.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.design_services_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('ابتدا آرایشگاه خود را ثبت کنید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await Get.toNamed(Routes.barberRegister);
                  if (result == 'addServices' && context.mounted) {
                    onShowSheet(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white),
                child: const Text('ثبت آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn')),
              ),
            ],
          ),
        );
      }
      final svcs = ctrl.services;
      if (svcs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.design_services_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('خدماتی اضافه نکرده‌اید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => onShowSheet(context),
                style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white),
                icon: const Icon(Icons.add),
                label: const Text('افزودن خدمت', style: TextStyle(fontFamily: 'Vazirmatn')),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: svcs.length,
        itemBuilder: (_, i) {
          final svc = svcs[i];
          return Dismissible(
            key: Key(svc.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: _kDanger, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('حذف خدمت', style: TextStyle(fontFamily: 'Vazirmatn')),
                  content: Text('آیا خدمت "${svc.name}" حذف شود؟', style: const TextStyle(fontFamily: 'Vazirmatn')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('خیر', style: TextStyle(fontFamily: 'Vazirmatn'))),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('بله، حذف شود', style: TextStyle(fontFamily: 'Vazirmatn', color: _kDanger)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) => ctrl.deleteService(svc.id),
            child: _ServiceCard(
              service: svc,
              onEdit: () => onShowSheet(context, editing: svc),
              onToggle: () => ctrl.updateService(svc.copyWith(isActive: !svc.isActive)),
            ),
          );
        },
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Service widgets (shared between sub-tab and sheets)
// ════════════════════════════════════════════════════════════════════════════

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _ServiceCard({required this.service, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: service.isActive ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: service.isActive ? _kPrimary.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.content_cut, color: service.isActive ? _kPrimary : Colors.grey, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: service.isActive ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      PersianUtils.formatPrice(service.price),
                      style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: service.isActive ? _kSuccess : Colors.grey),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${PersianUtils.toPersianDigits(service.durationMinutes.toString())} دقیقه',
                      style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: service.isActive,
            onChanged: (_) => onToggle(),
            activeColor: _kSuccess,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _kPrimary, size: 20),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _ServiceSheet extends StatefulWidget {
  final ServiceModel? editing;
  final String salonId;

  const _ServiceSheet({this.editing, required this.salonId});

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _nameCtrl.text = widget.editing!.name;
      _durationCtrl.text = widget.editing!.durationMinutes.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = OwnerController.to;
    final isEdit = widget.editing != null;
    final svc = ServiceModel(
      id: isEdit ? widget.editing!.id : 'sv_${DateTime.now().millisecondsSinceEpoch}',
      salonId: widget.salonId,
      name: _nameCtrl.text.trim(),
      price: 0,
      durationMinutes: int.parse(_durationCtrl.text.trim()),
      category: 'general',
      isActive: isEdit ? widget.editing!.isActive : true,
    );
    if (isEdit) {
      ctrl.updateService(svc);
    } else {
      ctrl.addService(svc);
    }
    Get.back();
    Get.snackbar(
      isEdit ? 'ویرایش شد' : 'اضافه شد',
      'خدمت "${svc.name}" ${isEdit ? "ویرایش" : "اضافه"} شد',
      backgroundColor: _kSuccess,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(
              widget.editing == null ? 'خدمت جدید' : 'ویرایش خدمت',
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: _kPrimary),
            ),
            const SizedBox(height: 16),
            _SheetField(
              controller: _nameCtrl,
              label: 'نام خدمت',
              icon: Icons.label_outline,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'نام الزامی است' : null,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _durationCtrl,
              label: 'مدت زمان (دقیقه)',
              icon: Icons.timer_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'مدت الزامی است';
                if (int.tryParse(v.trim()) == null) return 'عدد وارد کنید';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  widget.editing == null ? 'افزودن خدمت' : 'ذخیره تغییرات',
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 4 — Stats
// ════════════════════════════════════════════════════════════════════════════

class _StatsTab extends StatefulWidget {
  const _StatsTab();
  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  void _showDownloadDialog(BuildContext context, OwnerController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.download_outlined, color: _kPrimary),
              SizedBox(width: 10),
              Text('دریافت گزارش', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
            ],
          ),
          content: const Text('فرمت دریافت گزارش را انتخاب کنید:', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _exportCsv(ctrl);
              },
              icon: const Icon(Icons.table_chart_outlined, size: 18),
              label: const Text('اکسل (CSV)', style: TextStyle(fontFamily: 'Vazirmatn')),
              style: OutlinedButton.styleFrom(foregroundColor: _kSuccess),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _exportPdf(ctrl);
              },
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('PDF', style: TextStyle(fontFamily: 'Vazirmatn')),
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(OwnerController ctrl) async {
    try {
      final apts = ctrl.appointments.toList();
      final buf = StringBuffer();
      buf.writeln('تاریخ,زمان,مشتری,خدمت,وضعیت');
      for (final a in apts) {
        final date = '${a.date.year}/${a.date.month}/${a.date.day}';
        buf.writeln('"$date","${a.startTime}","${a.userName ?? '-'}","${a.serviceNames.join(' / ')}","${a.statusLabel}"');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/appointments_report.csv');
      await file.writeAsString(buf.toString());
      Get.snackbar('ذخیره شد', 'فایل CSV در پوشه موقت ذخیره شد\n${file.path}',
          backgroundColor: _kSuccess, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    } catch (e) {
      Get.snackbar('خطا', 'خطا در تولید فایل: $e', backgroundColor: _kDanger, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _exportPdf(OwnerController ctrl) async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);
      final boldData = await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf');
      final boldTtf = pw.Font.ttf(boldData);

      final apts = ctrl.appointments.toList();
      final now = DateTime.now();

      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'گزارش نوبت‌های آرایشگاه',
                style: pw.TextStyle(font: boldTtf, fontSize: 20),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'تاریخ تهیه: ${now.year}/${now.month}/${now.day}',
                style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _pdfStatBox(ttf, boldTtf, 'کل نوبت‌ها', '${apts.length}'),
                _pdfStatBox(ttf, boldTtf, 'این ماه', '${ctrl.monthAppointmentCount}'),
                _pdfStatBox(ttf, boldTtf, 'این هفته', '${ctrl.weekAppointmentCount}'),
                _pdfStatBox(ttf, boldTtf, 'امروز', '${ctrl.todayAppointments.length}'),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('جزئیات نوبت‌ها', style: pw.TextStyle(font: boldTtf, fontSize: 14), textDirection: pw.TextDirection.rtl),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0F3460)),
                  children: [
                    _pdfCell(boldTtf, 'مشتری', isHeader: true),
                    _pdfCell(boldTtf, 'تاریخ', isHeader: true),
                    _pdfCell(boldTtf, 'خدمت', isHeader: true),
                    _pdfCell(boldTtf, 'زمان', isHeader: true),
                    _pdfCell(boldTtf, 'وضعیت', isHeader: true),
                  ],
                ),
                ...apts.take(50).map((a) => pw.TableRow(
                  children: [
                    _pdfCell(ttf, a.userName ?? '-'),
                    _pdfCell(ttf, '${a.date.year}/${a.date.month}/${a.date.day}'),
                    _pdfCell(ttf, a.serviceNames.take(1).join()),
                    _pdfCell(ttf, a.startTime),
                    _pdfCell(ttf, a.statusLabel),
                  ],
                )),
              ],
            ),
          ],
        ),
      );

      await Printing.sharePdf(bytes: await doc.save(), filename: 'appointments_report.pdf');
    } catch (e) {
      Get.snackbar('خطا', 'خطا در تولید PDF: $e', backgroundColor: _kDanger, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  pw.Widget _pdfStatBox(pw.Font ttf, pw.Font boldTtf, String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(font: boldTtf, fontSize: 16, color: const PdfColor.fromInt(0xFF0F3460)), textDirection: pw.TextDirection.rtl),
          pw.SizedBox(height: 4),
          pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey), textDirection: pw.TextDirection.rtl),
        ],
      ),
    );
  }

  pw.Widget _pdfCell(pw.Font font, String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10, color: isHeader ? PdfColors.white : PdfColors.black),
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.right,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: _kPrimary,
        title: const Text('آمار و گزارشات', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, color: _kPrimary)),
        actions: [
          Obx(() => IconButton(
            icon: const Icon(Icons.download_outlined, color: _kPrimary),
            tooltip: 'دریافت گزارش',
            onPressed: () => _showDownloadDialog(context, OwnerController.to),
          )),
        ],
      ),
      body: Obx(() {
        final ctrl = OwnerController.to;
        final counts = ctrl.last7DaysAppointmentCount;
        final maxCount = counts.isEmpty ? 1 : (counts.reduce((a, b) => a > b ? a : b) == 0 ? 1 : counts.reduce((a, b) => a > b ? a : b));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _RevCard(label: 'امروز', value: PersianUtils.toPersianDigits(ctrl.todayAppointments.length.toString()), color: _kAccent),
                const SizedBox(width: 12),
                _RevCard(label: 'هفتگی', value: PersianUtils.toPersianDigits(ctrl.weekAppointmentCount.toString()), color: _kPrimary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _RevCard(label: 'ماهانه', value: PersianUtils.toPersianDigits(ctrl.monthAppointmentCount.toString()), color: _kSuccess),
                const SizedBox(width: 12),
                _RevCard(label: 'لغو شده', value: PersianUtils.toPersianDigits(ctrl.appointments.where((a) => a.status == AppointmentStatus.cancelled).length.toString()), color: _kDanger),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نوبت‌های ۷ روز گذشته', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
                  const SizedBox(height: 16),
                  SizedBox(height: 140, child: _BarChart(revenues: counts, maxValue: maxCount)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = DateTime.now().subtract(Duration(days: 6 - i));
                      return Expanded(
                        child: Text(
                          PersianUtils.toPersianDigits(day.day.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 10, color: Colors.grey),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('عملکرد', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
                  const SizedBox(height: 12),
                  _PerfRow(label: 'نرخ لغو', value: '${PersianUtils.toPersianDigits(ctrl.cancelRate.toStringAsFixed(1))}٪', color: ctrl.cancelRate > 20 ? _kDanger : _kSuccess),
                  _PerfRow(label: 'تعداد خدمات', value: PersianUtils.toPersianDigits(ctrl.services.length.toString()), color: _kPrimary),
                  _PerfRow(label: 'کل نوبت‌ها', value: PersianUtils.toPersianDigits(ctrl.appointments.length.toString()), color: _kAccent),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> revenues;
  final int maxValue;

  const _BarChart({required this.revenues, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(revenues.length, (i) {
        final ratio = revenues[i] / maxValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: 120 * ratio,
                  decoration: BoxDecoration(
                    color: i == revenues.length - 1 ? _kPrimary : _kAccent.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 5 — Owner Profile
// ════════════════════════════════════════════════════════════════════════════

class _OwnerProfileTab extends StatefulWidget {
  const _OwnerProfileTab();
  @override
  State<_OwnerProfileTab> createState() => _OwnerProfileTabState();
}

class _OwnerProfileTabState extends State<_OwnerProfileTab> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final avail = await BiometricService.isAvailable();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = avail;
      _biometricEnabled = StorageService.biometricEnabled;
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final u = StorageService.getUser();
    if (u == null) return;
    final updated = u.copyWith(avatarUrl: picked.path);
    await StorageService.saveUser(updated);
    final idx = MockData.users.indexWhere((x) => x.id == u.id);
    if (idx != -1) MockData.users[idx] = updated;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();
    final ctrl = OwnerController.to;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: _kPrimary,
        title: const Text('پروفایل', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, color: _kPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: user?.avatarUrl != null
                          ? DecorationImage(image: FileImage(File(user!.avatarUrl!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: user?.avatarUrl == null
                        ? const Icon(Icons.person, size: 56, color: _kPrimary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: _kPrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(user?.fullName ?? '—', style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w800, color: _kPrimary))),
          const SizedBox(height: 4),
          Center(child: Text(user?.phone ?? '—', style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey))),
          const SizedBox(height: 24),
          // Info card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Column(
              children: [
                _InfoRow(icon: Icons.person_outline, label: 'نام', value: user?.fullName ?? '—'),
                const Divider(height: 1),
                _InfoRow(icon: Icons.phone_outlined, label: 'شماره', value: user?.phone ?? '—'),
                if (user?.email != null) ...[
                  const Divider(height: 1),
                  _InfoRow(icon: Icons.email_outlined, label: 'ایمیل', value: user!.email!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Menu sections
          _OwnerMenuSection(title: 'حساب کاربری', items: [
            _OwnerMenuItem(Icons.edit_outlined, 'ویرایش پروفایل', () => _showEditProfile(context, user)),
            _OwnerMenuItem(Icons.star_outline, 'نظرات آرایشگاه', () => _showReviews(context, ctrl)),
          ]),
          const SizedBox(height: 12),
          if (_biometricAvailable) ...[
            Container(
              decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: SwitchListTile(
                secondary: const Icon(Icons.fingerprint, color: _kPrimary),
                title: const Text('ورود با اثر انگشت', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
                subtitle: const Text('فعال‌سازی بیومتریک برای ورود سریع', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: Colors.grey)),
                value: _biometricEnabled,
                activeColor: _kPrimary,
                onChanged: (v) async {
                  if (v) {
                    final ok = await BiometricService.authenticate();
                    if (!ok) return;
                  }
                  await StorageService.setBiometricEnabled(v);
                  if (mounted) setState(() => _biometricEnabled = v);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          _OwnerMenuSection(title: 'پشتیبانی', items: [
            _OwnerMenuItem(Icons.menu_book_outlined, 'راهنمای آرایشگر', () => Get.to(() => const _OwnerHelpPage())),
            _OwnerMenuItem(Icons.support_agent_outlined, 'پشتیبانی', () => Get.to(() => const _OwnerSupportPage())),
            _OwnerMenuItem(Icons.info_outline, 'درباره آراپوینت', () => Get.to(() => const _OwnerAboutPage())),
          ]),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await StorageService.logout();
              Get.offAllNamed(Routes.roleSelection);
            },
            style: OutlinedButton.styleFrom(side: const BorderSide(color: _kDanger), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.logout, color: _kDanger),
            label: const Text('خروج از حساب', style: TextStyle(fontFamily: 'Vazirmatn', color: _kDanger)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, user) {
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    String? passError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ویرایش پروفایل', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(labelText: 'نام و نام خانوادگی', labelStyle: const TextStyle(fontFamily: 'Vazirmatn'), prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  textDirection: TextDirection.rtl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'شماره موبایل', labelStyle: const TextStyle(fontFamily: 'Vazirmatn'), prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  textDirection: TextDirection.rtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'ایمیل (اختیاری)', labelStyle: const TextStyle(fontFamily: 'Vazirmatn'), prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                const Text('تغییر رمز عبور', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w600, color: _kPrimary)),
                const SizedBox(height: 4),
                const Text('در صورت عدم تغییر رمز، فیلدها را خالی بگذارید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: currentPwCtrl,
                  obscureText: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور فعلی',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPwCtrl,
                  obscureText: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور جدید',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.lock_open_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPwCtrl,
                  obscureText: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'تکرار رمز عبور جدید',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: passError,
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final u = StorageService.getUser();
                      if (u == null) return;
                      String? newPassword;
                      if (newPwCtrl.text.isNotEmpty) {
                        if (currentPwCtrl.text != u.password) {
                          setS(() => passError = 'رمز عبور فعلی اشتباه است');
                          return;
                        }
                        if (newPwCtrl.text.length < 6) {
                          setS(() => passError = 'رمز جدید باید حداقل ۶ کاراکتر باشد');
                          return;
                        }
                        if (newPwCtrl.text != confirmPwCtrl.text) {
                          setS(() => passError = 'رمز عبور جدید با تکرار آن مطابقت ندارد');
                          return;
                        }
                        newPassword = newPwCtrl.text;
                      }
                      setS(() => passError = null);
                      final updated = u.copyWith(
                        fullName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : u.fullName,
                        phone: phoneCtrl.text.trim().isEmpty ? u.phone : phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim().toLowerCase(),
                        password: newPassword ?? u.password,
                      );
                      await StorageService.saveUser(updated);
                      final idx = MockData.users.indexWhere((x) => x.id == u.id);
                      if (idx != -1) MockData.users[idx] = updated;
                      setState(() {});
                      Navigator.pop(ctx);
                      Get.snackbar('ذخیره شد', 'پروفایل با موفقیت به‌روز شد', backgroundColor: _kSuccess, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                      if (newPassword != null) {
                        Get.offAllNamed(Routes.ownerPanel);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('ذخیره تغییرات', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReviews(BuildContext context, OwnerController ctrl) {
    final salonId = ctrl.salon.value?.id;
    final reviews = salonId != null ? MockData.reviews.where((r) => r.salonId == salonId).toList() : <ReviewModel>[];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                const Text('نظرات آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ]),
            ),
            Expanded(
              child: reviews.isEmpty
                  ? const Center(child: Text('هنوز نظری ثبت نشده', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)))
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reviews.length,
                      itemBuilder: (_, i) {
                        final r = reviews[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(r.userName, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Row(children: List.generate(5, (j) => Icon(j < r.rating ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 14))),
                            ]),
                            const SizedBox(height: 6),
                            Text(r.comment, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.black87, height: 1.5)),
                          ]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

}

class _OwnerMenuSection extends StatelessWidget {
  final String title;
  final List<_OwnerMenuItem> items;
  const _OwnerMenuSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(children: [
                ListTile(
                  leading: Icon(e.value.icon, color: _kPrimary, size: 22),
                  title: Text(e.value.label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
                  onTap: e.value.onTap,
                  dense: true,
                ),
                if (!isLast) const Divider(height: 1, indent: 56),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _OwnerMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _OwnerMenuItem(this.icon, this.label, this.onTap);
}

// ════════════════════════════════════════════════════════════════════════════
// Shared widgets
// ════════════════════════════════════════════════════════════════════════════

class _AptCard extends StatelessWidget {
  final AppointmentModel apt;
  final bool showActions;
  const _AptCard({required this.apt, this.showActions = false});

  Color get _statusColor {
    switch (apt.status) {
      case AppointmentStatus.pending: return _kWarning;
      case AppointmentStatus.confirmed: return _kSuccess;
      case AppointmentStatus.done: return _kPrimary;
      case AppointmentStatus.cancelled: return _kDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = OwnerController.to;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        border: Border(right: BorderSide(color: _statusColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                PersianUtils.formatTime(apt.startTime),
                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary),
              ),
              const SizedBox(width: 8),
              Text(
                '← ${PersianUtils.formatTime(apt.endTime)}',
                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(apt.statusLabel, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (apt.userName != null || apt.userPhone != null) ...[
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                if (apt.userName != null)
                  Text(apt.userName!, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
                if (apt.userName != null && apt.userPhone != null)
                  const Text(' — ', style: TextStyle(color: Colors.grey)),
                if (apt.userPhone != null)
                  Text(apt.userPhone!, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(apt.serviceNames.join('، '), style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            PersianUtils.gregorianToJalali(apt.date),
            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey),
          ),
          if (apt.status == AppointmentStatus.cancelled && apt.notes != null && apt.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _kDanger.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kDanger.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 13, color: _kDanger),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'دلیل لغو: ${apt.notes!}',
                      style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: _kDanger, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showActions && (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.confirmed)) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (apt.status == AppointmentStatus.pending)
                  _AptAction(label: 'تأیید', color: _kSuccess, icon: Icons.check_circle_outline, onTap: () => ctrl.confirmAppointment(apt.id)),
                if (apt.status == AppointmentStatus.confirmed) ...[
                  _AptAction(label: 'انجام شد', color: _kPrimary, icon: Icons.done_all, onTap: () => ctrl.completeAppointment(apt.id)),
                  const SizedBox(width: 8),
                ],
                const SizedBox(width: 8),
                _AptAction(label: 'لغو', color: _kDanger, icon: Icons.cancel_outlined, onTap: () => _showCancelDialog(context, ctrl, apt.id)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

void _showCancelDialog(BuildContext context, OwnerController ctrl, String aptId) {
  final reasonCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('لغو نوبت', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('دلیل لغو (اختیاری):', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'توضیحات...',
                hintStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ctrl.cancelAppointmentByOwner(aptId, reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim());
              Navigator.pop(ctx);
              Get.snackbar('لغو شد', 'نوبت با موفقیت لغو شد', backgroundColor: _kDanger, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kDanger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('لغو نوبت', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );
}

class _AptAction extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _AptAction({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                  Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _RevCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RevCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _PerfRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PerfRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.grey))),
          Text(value, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kPrimary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, this.color = _kPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: _kPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: _kPrimary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WorkingDayRow extends StatelessWidget {
  final String dayName;
  final bool isOff;
  final String start;
  final String end;
  final bool isLast;
  final ValueChanged<bool> onToggle;
  final void Function(bool isStart) onTimeTap;

  const _WorkingDayRow({
    required this.dayName,
    required this.isOff,
    required this.start,
    required this.end,
    required this.isLast,
    required this.onToggle,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  dayName,
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: isOff ? Colors.grey : Colors.black87),
                ),
              ),
              Switch(value: !isOff, onChanged: onToggle, activeColor: _kSuccess, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
              const Spacer(),
              if (!isOff) ...[
                GestureDetector(onTap: () => onTimeTap(true), child: _TimeChip(time: start)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('تا', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
                ),
                GestureDetector(onTap: () => onTimeTap(false), child: _TimeChip(time: end)),
              ] else
                const Text('تعطیل', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  const _TimeChip({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: Text(
        PersianUtils.toPersianDigits(time),
        style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary),
      ),
    );
  }
}

class _EditSalonSheet extends StatefulWidget {
  final SalonModel salon;
  const _EditSalonSheet({required this.salon});
  @override
  State<_EditSalonSheet> createState() => _EditSalonSheetState();
}

class _EditSalonSheetState extends State<_EditSalonSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _phoneCtrl;
  late SalonCategory _category;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late double _lat;
  late double _lng;
  late bool _locationEnabled;
  late List<String> _images;
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _editMapController = MapController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.salon.name);
    _addressCtrl = TextEditingController(text: widget.salon.address);
    _descCtrl = TextEditingController(text: widget.salon.description);
    _phoneCtrl = TextEditingController(text: widget.salon.phone ?? '');
    _category = widget.salon.category == SalonCategory.unisex ? SalonCategory.male : widget.salon.category;
    // Parse openTime / closeTime strings (e.g. "09:00")
    _startTime = _parseTime(widget.salon.openTime) ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _parseTime(widget.salon.closeTime) ?? const TimeOfDay(hour: 21, minute: 0);
    _lat = widget.salon.lat;
    _lng = widget.salon.lng;
    _locationEnabled = widget.salon.lat != 0.0 && widget.salon.lng != 0.0;
    _images = List<String>.from(widget.salon.images);
  }

  TimeOfDay? _parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _images.add(picked.path));
    }
  }

  Future<void> _pickLocation() async {
    final result = await Get.toNamed(
      Routes.locationPicker,
      arguments: _locationEnabled ? LatLng(_lat, _lng) : null,
    );
    if (result != null && result is LatLng) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _locationEnabled = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try { _editMapController.move(LatLng(_lat, _lng), 15); } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _descCtrl.dispose(); _phoneCtrl.dispose();
    _editMapController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    OwnerController.to.updateSalon(widget.salon.copyWith(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      category: _category,
      openTime: _formatTime(_startTime),
      closeTime: _formatTime(_endTime),
      lat: _locationEnabled ? _lat : 0.0,
      lng: _locationEnabled ? _lng : 0.0,
      images: _images,
    ));
    Get.back();
    Get.snackbar('ذخیره شد', 'اطلاعات آرایشگاه به‌روز شد', backgroundColor: _kSuccess, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(color: _kSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('ویرایش اطلاعات آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: _kPrimary)),
              const SizedBox(height: 16),
              _SheetField(controller: _nameCtrl, label: 'نام آرایشگاه', icon: Icons.store_outlined, validator: (v) => (v == null || v.trim().length < 2) ? 'نام باید حداقل ۲ کاراکتر باشد' : null),
              const SizedBox(height: 12),
              _SheetField(controller: _phoneCtrl, label: 'شماره تماس (اختیاری)', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _SheetField(controller: _addressCtrl, label: 'آدرس', icon: Icons.location_on_outlined, validator: (v) => (v == null || v.trim().length < 5) ? 'آدرس باید حداقل ۵ کاراکتر باشد' : null),
              const SizedBox(height: 12),
              // Category chips
              Row(
                children: [
                  _CatChip(label: 'مردانه', icon: Icons.man_outlined, selected: _category == SalonCategory.male, onTap: () => setState(() => _category = SalonCategory.male)),
                  const SizedBox(width: 8),
                  _CatChip(label: 'زنانه', icon: Icons.woman_outlined, selected: _category == SalonCategory.female, onTap: () => setState(() => _category = SalonCategory.female)),
                ],
              ),
              const SizedBox(height: 12),
              // Working hours
              const Text('ساعت کاری', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 16, color: _kPrimary),
                            const SizedBox(width: 6),
                            Text(_formatTime(_startTime), style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: _kPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('تا', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.nights_stay_outlined, size: 16, color: _kPrimary),
                            const SizedBox(width: 6),
                            Text(_formatTime(_endTime), style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: _kPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SheetField(controller: _descCtrl, label: 'توضیحات', icon: Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 12),
              // Location section
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('موقعیت مکانی', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
                        Text('اختیاری', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _locationEnabled,
                    onChanged: (v) => setState(() => _locationEnabled = v),
                    activeColor: _kPrimary,
                  ),
                ],
              ),
              if (_locationEnabled) ...[
                const SizedBox(height: 8),
                if (_lat != 0.0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 160,
                      child: FlutterMap(
                        mapController: _editMapController,
                        options: MapOptions(
                          initialCenter: LatLng(_lat, _lng),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.barberbook.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_lat, _lng),
                                width: 36,
                                height: 36,
                                child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kPrimary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_pin, color: _kPrimary, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _lat != 0.0
                                ? 'طول: ${_lat.toStringAsFixed(4)} | عرض: ${_lng.toStringAsFixed(4)}'
                                : 'برای انتخاب روی نقشه ضربه بزنید',
                            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: _kPrimary),
                          ),
                        ),
                        const Icon(Icons.edit_location_alt_outlined, color: _kPrimary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Images section
              const Text('تصاویر آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...List.generate(_images.length, (i) => Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kPrimary.withOpacity(0.3)),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.file(File(_images[i]), fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 3,
                            right: 3,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(i)),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (_images.length < 5)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 24),
                              SizedBox(height: 4),
                              Text('افزودن', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('ذخیره', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
        prefixIcon: Icon(icon, color: _kPrimary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _CatChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _kPrimary.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? _kPrimary : Colors.grey.shade200, width: selected ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? _kPrimary : Colors.grey, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: selected ? _kPrimary : Colors.grey, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Full-page screens for barber profile
// ════════════════════════════════════════════════════════════════════════════

class _OwnerAboutPage extends StatelessWidget {
  const _OwnerAboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('درباره آراپوینت', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: _kPrimary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.content_cut, color: _kPrimary, size: 52),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('آراپوینت', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 26, fontWeight: FontWeight.w900, color: _kPrimary))),
          const SizedBox(height: 4),
          const Center(child: Text('پلتفرم هوشمند نوبت‌دهی آرایشگاه', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey))),
          const SizedBox(height: 32),
          _AboutCard(
            icon: Icons.info_outline,
            title: 'نسخه برنامه',
            content: '۱.۰.۰ — نسخه پایدار',
          ),
          const SizedBox(height: 12),
          _AboutCard(
            icon: Icons.business,
            title: 'شرکت سازنده',
            content: 'تیم توسعه آراپوینت\nاعتماد، کیفیت، نوآوری',
          ),
          const SizedBox(height: 12),
          _AboutCard(
            icon: Icons.language,
            title: 'وب‌سایت',
            content: 'www.arapoint.ir',
          ),
          const SizedBox(height: 12),
          _AboutCard(
            icon: Icons.shield_outlined,
            title: 'حریم خصوصی',
            content: 'اطلاعات کاربران نزد ما کاملاً محرمانه است. هیچ داده‌ای بدون اجازه کاربر به اشتراک گذاشته نمی‌شود.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _kPrimary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                Text('© ۲۰۲۴ آراپوینت — تمام حقوق محفوظ است', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _AboutCard({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _kPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w700, color: _kPrimary)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.black87, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerSupportPage extends StatelessWidget {
  const _OwnerSupportPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('پشتیبانی', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kPrimary, _kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 52),
                SizedBox(height: 12),
                Text('تیم پشتیبانی آراپوینت', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 4),
                Text('آماده پاسخگویی ۲۴ ساعته هستیم', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('راه‌های ارتباطی', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
          const SizedBox(height: 12),
          _SupportItem(icon: Icons.phone_outlined, label: 'تلفن پشتیبانی', value: '۰۲۱-۱۲۳۴۵۶۷۸', color: _kSuccess),
          const SizedBox(height: 10),
          _SupportItem(icon: Icons.email_outlined, label: 'ایمیل پشتیبانی', value: 'support@arapoint.ir', color: _kAccent),
          const SizedBox(height: 10),
          _SupportItem(icon: Icons.chat_bubble_outline, label: 'چت آنلاین', value: 'از طریق اپلیکیشن در دسترس است', color: _kPrimary),
          const SizedBox(height: 24),
          const Text('ساعت پاسخگویی', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: const Column(
              children: [
                _SupportHourRow(days: 'شنبه تا پنجشنبه', hours: '۸:۰۰ — ۲۱:۰۰'),
                Divider(height: 16),
                _SupportHourRow(days: 'جمعه', hours: '۱۰:۰۰ — ۱۸:۰۰'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SupportItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportHourRow extends StatelessWidget {
  final String days;
  final String hours;
  const _SupportHourRow({required this.days, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(days, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.black87))),
        Text(hours, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
      ],
    );
  }
}

class _OwnerHelpPage extends StatelessWidget {
  const _OwnerHelpPage();

  static const _faqs = [
    _FaqItem(
      question: 'چطور آرایشگاهم را ثبت کنم؟',
      answer: 'از داشبورد یا تب آرایشگاه، روی "ثبت آرایشگاه" کلیک کنید. اطلاعات نام، آدرس، دسته‌بندی و ساعت کاری را وارد کرده و ثبت کنید.',
    ),
    _FaqItem(
      question: 'چطور خدمات اضافه کنم؟',
      answer: 'در تب آرایشگاه → قسمت خدمات، دکمه + را بزنید. نام خدمت و مدت زمان آن را وارد کنید.',
    ),
    _FaqItem(
      question: 'چطور نوبت را تأیید یا لغو کنم؟',
      answer: 'در تب نوبت‌ها، کارت هر نوبت دارای دکمه‌های "تأیید"، "انجام شد" و "لغو" است. پس از تأیید، مشتری مطلع می‌شود.',
    ),
    _FaqItem(
      question: 'چطور تصاویر آرایشگاه اضافه کنم؟',
      answer: 'در تب آرایشگاه → ویرایش اطلاعات، قسمت تصاویر آرایشگاه وجود دارد. می‌توانید تا ۵ تصویر اضافه کنید.',
    ),
    _FaqItem(
      question: 'آیا می‌توانم ساعت کاری روزانه را تنظیم کنم؟',
      answer: 'بله. در تب آرایشگاه، بخش ساعت کاری نمایش داده می‌شود. برای هر روز می‌توانید ساعت شروع و پایان، یا تعطیل بودن را تنظیم کنید.',
    ),
    _FaqItem(
      question: 'چطور درآمد و آمار ببینم؟',
      answer: 'تب آمار شامل درآمد روزانه، هفتگی و ماهانه، نمودار ۷ روز گذشته و آمار عملکرد می‌باشد.',
    ),
    _FaqItem(
      question: 'چطور پروفایل خود را ویرایش کنم؟',
      answer: 'در تب پروفایل، روی "ویرایش پروفایل" کلیک کنید. می‌توانید نام، شماره، ایمیل و رمز عبور را تغییر دهید.',
    ),
    _FaqItem(
      question: 'مشتری نوبت را لغو کرده، چه کار کنم؟',
      answer: 'نوبت‌های لغو شده در تب "همه" با رنگ قرمز نمایش داده می‌شوند. دلیل لغو (در صورت وجود) نیز نمایش داده می‌شود.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('راهنمای آرایشگر', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kAccent.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.menu_book_outlined, color: _kAccent, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سؤالات متداول آرایشگران',
                    style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._faqs.map((faq) => _FaqCard(item: faq)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqCard extends StatefulWidget {
  final _FaqItem item;
  const _FaqCard({required this.item});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        border: Border.all(color: _expanded ? _kPrimary.withOpacity(0.3) : Colors.transparent),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          leading: Icon(Icons.help_outline, color: _expanded ? _kPrimary : Colors.grey, size: 22),
          title: Text(
            widget.item.question,
            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: _expanded ? _kPrimary : Colors.black87),
          ),
          children: [
            Text(widget.item.answer, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.black87, height: 1.7)),
          ],
        ),
      ),
    );
  }
}
