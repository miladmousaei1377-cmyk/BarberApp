import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../controllers/owner_controller.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/models/appointment_model.dart';
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

// ════════════════════════════════════════════════════════════════════════════
// Main screen  —  tabs: داشبورد / نوبت‌ها / سالن / آمار / پروفایل
// ════════════════════════════════════════════════════════════════════════════

class BarberPanelScreen extends StatefulWidget {
  const BarberPanelScreen({super.key});
  @override
  State<BarberPanelScreen> createState() => _BarberPanelScreenState();
}

class _BarberPanelScreenState extends State<BarberPanelScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Get.put(OwnerController());
  }

  @override
  void dispose() {
    Get.delete<OwnerController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          _AppointmentsTab(),
          _SalonManagementTab(),
          _StatsTab(),
          _OwnerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
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
            label: 'سالن',
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
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 1 — Dashboard
// ════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

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
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        label: 'درآمد امروز',
                        value: PersianUtils.formatPriceShort(ctrl.todayRevenue),
                        icon: Icons.payments_outlined,
                        color: _kSuccess,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'درآمد ماه',
                        value: PersianUtils.formatPriceShort(ctrl.monthRevenue),
                        icon: Icons.trending_up,
                        color: _kPrimary,
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        label: 'نوبت‌های ماه',
                        value: PersianUtils.toPersianDigits(ctrl.monthAppointmentCount.toString()),
                        icon: Icons.people_outline,
                        color: _kWarning,
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
                            'هنوز سالنی ثبت نکرده‌اید',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'برای دریافت نوبت، ابتدا سالن خود را ثبت کنید',
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
                            label: const Text('ثبت سالن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
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
  const _AppointmentsTab();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('نوبت‌ها', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
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
        itemBuilder: (_, i) => _AptCard(apt: apts[i], showActions: true),
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
                    itemBuilder: (_, i) => _AptCard(apt: dayApts[i], showActions: true),
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
                    itemBuilder: (_, i) => _AptCard(apt: apts[i], showActions: true),
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
      Get.snackbar('توجه', 'ابتدا سالن خود را ثبت کنید', backgroundColor: _kWarning, colorText: Colors.black);
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
        title: const Text('سالن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
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
              const Text('سالنی ثبت نشده است', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('برای شروع، سالن خود را ثبت کنید', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
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
                label: const Text('ثبت سالن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
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
            title: 'ویرایش اطلاعات سالن',
            subtitle: salon.address,
            onTap: () => _showEditSalonSheet(context, salon),
          ),
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
              const Text('ابتدا سالن خود را ثبت کنید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await Get.toNamed(Routes.barberRegister);
                  if (result == 'addServices' && context.mounted) {
                    onShowSheet(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white),
                child: const Text('ثبت سالن', style: TextStyle(fontFamily: 'Vazirmatn')),
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
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _nameCtrl.text = widget.editing!.name;
      _priceCtrl.text = widget.editing!.price.toString();
      _durationCtrl.text = widget.editing!.durationMinutes.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
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
      price: int.parse(_priceCtrl.text.trim()),
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
            Row(
              children: [
                Expanded(
                  child: _SheetField(
                    controller: _priceCtrl,
                    label: 'قیمت (تومان)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'الزامی';
                      if (int.tryParse(v.trim()) == null) return 'عدد وارد کنید';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetField(
                    controller: _durationCtrl,
                    label: 'مدت (دقیقه)',
                    icon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'الزامی';
                      if (int.tryParse(v.trim()) == null) return 'عدد وارد کنید';
                      return null;
                    },
                  ),
                ),
              ],
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

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('آمار و درآمد', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        final ctrl = OwnerController.to;
        final revenues = ctrl.last7DaysRevenue;
        final maxRev = revenues.isEmpty ? 1 : (revenues.reduce((a, b) => a > b ? a : b) == 0 ? 1 : revenues.reduce((a, b) => a > b ? a : b));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _RevCard(label: 'امروز', value: PersianUtils.formatPriceShort(ctrl.todayRevenue), color: _kAccent),
                const SizedBox(width: 12),
                _RevCard(label: 'هفتگی', value: PersianUtils.formatPriceShort(ctrl.weekRevenue), color: _kPrimary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _RevCard(label: 'ماهانه', value: PersianUtils.formatPriceShort(ctrl.monthRevenue), color: _kSuccess),
                const SizedBox(width: 12),
                _RevCard(label: 'نوبت‌های ماه', value: PersianUtils.toPersianDigits(ctrl.monthAppointmentCount.toString()), color: _kWarning),
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
                  const Text('درآمد ۷ روز گذشته', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
                  const SizedBox(height: 16),
                  SizedBox(height: 140, child: _BarChart(revenues: revenues, maxValue: maxRev)),
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

class _OwnerProfileTab extends StatelessWidget {
  const _OwnerProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('پروفایل', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 56, color: _kPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.fullName ?? '—',
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w800, color: _kPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.phone ?? '—',
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
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
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await StorageService.logout();
              Get.offAllNamed(Routes.roleSelection);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kDanger),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout, color: _kDanger),
            label: const Text('خروج از حساب', style: TextStyle(fontFamily: 'Vazirmatn', color: _kDanger)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
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
          Text(apt.serviceNames.join('، '), style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            PersianUtils.gregorianToJalali(apt.date),
            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.grey),
          ),
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
                _AptAction(label: 'لغو', color: _kDanger, icon: Icons.cancel_outlined, onTap: () => ctrl.cancelAppointmentByOwner(apt.id)),
              ],
            ),
          ],
        ],
      ),
    );
  }
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
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.salon.name);
    _addressCtrl = TextEditingController(text: widget.salon.address);
    _descCtrl = TextEditingController(text: widget.salon.description);
    _phoneCtrl = TextEditingController(text: widget.salon.phone ?? '');
    _category = widget.salon.category == SalonCategory.unisex ? SalonCategory.male : widget.salon.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _descCtrl.dispose(); _phoneCtrl.dispose();
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
    ));
    Get.back();
    Get.snackbar('ذخیره شد', 'اطلاعات سالن به‌روز شد', backgroundColor: _kSuccess, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
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
              const Text('ویرایش اطلاعات سالن', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: _kPrimary)),
              const SizedBox(height: 16),
              _SheetField(controller: _nameCtrl, label: 'نام سالن', icon: Icons.store_outlined, validator: (v) => (v == null || v.trim().length < 2) ? 'نام باید حداقل ۲ کاراکتر باشد' : null),
              const SizedBox(height: 12),
              _SheetField(controller: _addressCtrl, label: 'آدرس', icon: Icons.location_on_outlined, validator: (v) => (v == null || v.trim().length < 5) ? 'آدرس باید حداقل ۵ کاراکتر باشد' : null),
              const SizedBox(height: 12),
              _SheetField(controller: _phoneCtrl, label: 'شماره تماس (اختیاری)', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _SheetField(controller: _descCtrl, label: 'توضیحات', icon: Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CatChip(label: 'مردانه', icon: Icons.man_outlined, selected: _category == SalonCategory.male, onTap: () => setState(() => _category = SalonCategory.male)),
                  const SizedBox(width: 8),
                  _CatChip(label: 'زنانه', icon: Icons.woman_outlined, selected: _category == SalonCategory.female, onTap: () => setState(() => _category = SalonCategory.female)),
                ],
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
