import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _user = StorageService.getUser();
    _biometricEnabled = StorageService.biometricEnabled;
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService.isAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final ok = await BiometricService.authenticate();
      if (!ok) return;
    }
    await StorageService.setBiometricEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('خروج', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        content: const Text('آیا می‌خواهید از حساب خود خارج شوید؟',
            style: TextStyle(fontFamily: 'Vazirmatn'), textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.logout();
              Get.offAllNamed(Routes.roleSelection);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('خروج', style: TextStyle(fontFamily: 'Vazirmatn')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    final appointments = MockData.getAppointmentsByUser(_user!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          _user!.fullName.characters.first,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showEditProfile(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _user!.fullName,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user!.phone,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 14,
                    color: Colors.white60,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatItem(
                      label: 'رزروها',
                      value: PersianUtils.toPersianDigits(appointments.length.toString()),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    _StatItem(
                      label: 'انجام شده',
                      value: PersianUtils.toPersianDigits(
                        appointments.where((a) => a.status.name == 'done').length.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Menu items
          _MenuSection(
            title: 'حساب کاربری',
            items: [
              _MenuItem(Icons.person_outline, 'ویرایش پروفایل', () => _showEditProfile(context)),
              _MenuItem(Icons.notifications_outlined, 'اعلان‌ها', () => Get.to(() => const _NotificationsPage())),
            ],
          ),
          if (_biometricAvailable) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: SwitchListTile(
                secondary: const Icon(Icons.fingerprint, color: AppColors.primary, size: 22),
                title: const Text('ورود با اثر انگشت', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: AppColors.textPrimary)),
                subtitle: const Text('فعال‌سازی ورود بیومتریک', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary)),
                value: _biometricEnabled,
                activeColor: AppColors.primary,
                onChanged: _toggleBiometric,
              ),
            ),
          ],
          _MenuSection(
            title: 'رزروها',
            items: [
              _MenuItem(Icons.history, 'تاریخچه رزروها', () => Get.to(() => _BookingHistoryPage(userId: _user!.id))),
            ],
          ),
          _MenuSection(
            title: 'پشتیبانی',
            items: [
              _MenuItem(Icons.help_outline, 'راهنما', () => Get.to(() => const _HelpPage())),
              _MenuItem(Icons.chat_outlined, 'پشتیبانی', () => Get.to(() => const _SupportPage())),
              _MenuItem(Icons.info_outline, 'درباره آراپوینت', () => Get.to(() => const _AboutPage())),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'خروج از حساب',
                style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'آراپوینت نسخه ۱.۰.۰',
              style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: _user?.fullName);
    final phoneCtrl = TextEditingController(text: _user?.phone);
    final emailCtrl = TextEditingController(text: _user?.email ?? '');
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? passError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ویرایش پروفایل',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  textDirection: TextDirection.rtl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'شماره موبایل',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  textDirection: TextDirection.rtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'ایمیل (اختیاری)',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn'),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'تغییر رمز عبور',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'در صورت عدم تغییر رمز، فیلدها را خالی بگذارید',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: currentPassCtrl,
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
                const SizedBox(height: 12),
                TextField(
                  controller: newPassCtrl,
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
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassCtrl,
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().length < 2) return;
                      String? newPassword;
                      if (newPassCtrl.text.isNotEmpty) {
                        if (currentPassCtrl.text != (_user?.password ?? '')) {
                          setInner(() => passError = 'رمز عبور فعلی اشتباه است');
                          return;
                        }
                        if (newPassCtrl.text.length < 6) {
                          setInner(() => passError = 'رمز جدید باید حداقل ۶ کاراکتر باشد');
                          return;
                        }
                        if (newPassCtrl.text != confirmPassCtrl.text) {
                          setInner(() => passError = 'رمز عبور جدید با تکرار آن مطابقت ندارد');
                          return;
                        }
                        newPassword = newPassCtrl.text;
                      }
                      setInner(() => passError = null);
                      final updated = _user!.copyWith(
                        fullName: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim().isEmpty ? _user!.phone : phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim().toLowerCase(),
                        password: newPassword ?? _user!.password,
                      );
                      await StorageService.saveUser(updated);
                      final idx = MockData.users.indexWhere((x) => x.id == _user!.id);
                      if (idx != -1) MockData.users[idx] = updated;
                      setState(() => _user = updated);
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      Get.snackbar('ذخیره شد', 'اطلاعات با موفقیت ذخیره شد', backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                      if (newPassword != null) {
                        Get.offAllNamed(Routes.main);
                      }
                    },
                    child: const Text('ذخیره', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.primary, size: 22),
                    title: Text(item.label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
                    onTap: item.onTap,
                    dense: true,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.label, this.onTap);
}

// ── Sub-pages ──────────────────────────────────────────────

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        leading: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => Get.back()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined, size: 72, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('هیچ اعلانی ندارید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('اعلان‌های جدید اینجا نمایش داده می‌شوند', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _BookingHistoryPage extends StatelessWidget {
  final String userId;

  const _BookingHistoryPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    final appointments = MockData.getAppointmentsByUser(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه رزروها'),
        leading: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => Get.back()),
      ),
      body: appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 72, color: AppColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('هیچ رزروی ندارید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (_, i) => _AppointmentCard(appointment: appointments[i]),
            ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.done:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  String get _statusLabel {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return 'در انتظار';
      case AppointmentStatus.confirmed:
        return 'تأیید شده';
      case AppointmentStatus.done:
        return 'انجام شده';
      case AppointmentStatus.cancelled:
        return 'لغو شده';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.content_cut, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.serviceNames.join('، '),
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${PersianUtils.gregorianToJalali(appointment.date)} | ${appointment.startTime}',
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: _statusColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();

  static const _faqs = [
    ('چطور نوبت رزرو کنم؟', 'از صفحه اصلی یک آرایشگاه انتخاب کرده، سپس روی دکمه «رزرو نوبت» کلیک کنید. تاریخ، ساعت و خدمت مورد نظر را انتخاب و نوبت خود را تأیید کنید.'),
    ('چطور نوبت را لغو کنم؟', 'از بخش «تاریخچه رزروها» در پروفایل، نوبت مورد نظر را انتخاب کرده و گزینه لغو را بزنید.'),
    ('چطور آرایشگاه مورد نظرم را پیدا کنم؟', 'از صفحه اصلی می‌توانید آرایشگاه‌ها را بر اساس دسته‌بندی (مردانه/زنانه) فیلتر کنید.'),
    ('آیا می‌توانم نظر بدهم؟', 'بله، پس از ورود به صفحه آرایشگاه، در تب «نظرات» می‌توانید نظر و امتیاز خود را ثبت کنید.'),
    ('رمز عبور را فراموش کرده‌ام، چه کنم؟', 'از صفحه ورود روی «فراموشی رمز عبور» کلیک کرده و از طریق ایمیل یا شماره موبایل رمز جدید تعریف کنید.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('راهنما'),
        leading: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => Get.back()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_center_outlined, color: AppColors.secondary, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'پرسش‌های متداول',
                    style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          ..._faqs.map((faq) => _FaqItem(question: faq.$1, answer: faq.$2)),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.question, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            trailing: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _expanded ? 0.5 : 0,
              child: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondary),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                textDirection: TextDirection.rtl,
              ),
            ),
        ],
      ),
    );
  }
}

class _SupportPage extends StatelessWidget {
  const _SupportPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پشتیبانی'),
        leading: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => Get.back()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.support_agent_outlined, color: AppColors.secondary, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('تیم پشتیبانی آراپوینت', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('ما اینجاییم تا کمک کنیم!', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SupportItem(icon: Icons.phone_outlined, title: 'تلفن پشتیبانی', subtitle: '۰۲۱-۱۲۳۴۵۶۷۸', color: Colors.green),
          const SizedBox(height: 12),
          _SupportItem(icon: Icons.email_outlined, title: 'ایمیل پشتیبانی', subtitle: 'support@arapoint.ir', color: Colors.blue),
          const SizedBox(height: 12),
          _SupportItem(icon: Icons.chat_bubble_outline, title: 'چت آنلاین', subtitle: 'شنبه تا پنجشنبه ۹ تا ۱۸', color: Colors.purple),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time_outlined, color: Colors.orange, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ساعت پاسخگویی: شنبه تا پنجشنبه ۸:۰۰ الی ۲۰:۰۰',
                    style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textPrimary),
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

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SupportItem({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: AppColors.textSecondary.withOpacity(0.5)),
        ],
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره آراپوینت'),
        leading: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => Get.back()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: const Center(
                child: Icon(Icons.content_cut, color: AppColors.secondary, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('آراپوینت', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('نسخه ۱.۰.۰', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 32),
          _AboutSection(
            title: 'معرفی اپلیکیشن',
            content: 'آراپوینت یک پلتفرم نوبت‌دهی هوشمند برای آرایشگاه‌ها است که ارتباط میان مشتریان و آرایشگران را آسان‌تر می‌کند. با آراپوینت به راحتی نوبت خود را رزرو کنید و از خدمات بهترین آرایشگاه‌ها بهره‌مند شوید.',
          ),
          const SizedBox(height: 16),
          _AboutSection(
            title: 'تماس با ما',
            content: 'وب‌سایت: arapoint.ir\nایمیل: info@arapoint.ir\nتلفن: ۰۲۱-۱۲۳۴۵۶۷۸',
          ),
          const SizedBox(height: 16),
          _AboutSection(
            title: 'حقوق قانونی',
            content: '© ۱۴۰۳ آراپوینت. تمامی حقوق محفوظ است.',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: const Text(
              'ساخته شده با ❤️ برای آرایشگران و مشتریان ایرانی',
              style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final String content;

  const _AboutSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary, height: 1.7), textDirection: TextDirection.rtl),
        ],
      ),
    );
  }
}
