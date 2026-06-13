import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = StorageService.getUser();
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
              await StorageService.clear();
              Get.offAllNamed(Routes.phone);
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
              _MenuItem(Icons.notifications_outlined, 'اعلان‌ها', () {}),
            ],
          ),
          _MenuSection(
            title: 'رزروها',
            items: [
              _MenuItem(Icons.history, 'تاریخچه رزروها', () {}),
              _MenuItem(Icons.star_outline, 'نظرات من', () {}),
            ],
          ),
          _MenuSection(
            title: 'پشتیبانی',
            items: [
              _MenuItem(Icons.help_outline, 'راهنما', () {}),
              _MenuItem(Icons.chat_outlined, 'پشتیبانی', () {}),
              _MenuItem(Icons.info_outline, 'درباره آراپوینت', () {}),
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
          Center(
            child: Text(
              'آراپوینت نسخه ۱.۰.۰',
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameController = TextEditingController(text: _user?.fullName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ویرایش پروفایل',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
                labelStyle: TextStyle(fontFamily: 'Vazirmatn'),
              ),
              style: const TextStyle(fontFamily: 'Vazirmatn'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().length >= 2) {
                    final updated = _user!.copyWith(fullName: nameController.text.trim());
                    await StorageService.saveUser(updated);
                    setState(() => _user = updated);
                    Navigator.pop(context);
                  }
                },
                child: const Text('ذخیره', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
              ),
            ),
          ],
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
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12,
            color: Colors.white60,
          ),
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
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.primary, size: 22),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
                    onTap: item.onTap,
                    dense: true,
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 56, color: AppColors.divider),
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
