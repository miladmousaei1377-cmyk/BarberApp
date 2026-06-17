import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 64),
              ),
              const SizedBox(height: 32),
              const Text(
                'در حال بررسی',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user != null
                    ? 'سلام ${user.fullName}،\nثبت‌نام شما با موفقیت انجام شد.'
                    : 'ثبت‌نام شما با موفقیت انجام شد.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, color: Colors.white70, height: 1.6),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text(
                  'اطلاعات و مدارک شما توسط تیم آرایش پلاس در حال بررسی است. '
                  'پس از تأیید، از طریق ایمیل به شما اطلاع‌رسانی خواهد شد. '
                  'این فرآیند معمولاً کمتر از ۲۴ ساعت طول می‌کشد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: Colors.white54,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await StorageService.logout();
                    Get.offAllNamed(Routes.roleSelection);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white54),
                  label: const Text(
                    'خروج از حساب',
                    style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white54, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
