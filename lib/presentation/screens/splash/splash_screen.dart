import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/services/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _poleController;
  bool _showOnboarding = false;
  bool _biometricFailed = false;

  @override
  void initState() {
    super.initState();
    _poleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _navigate();
  }

  @override
  void dispose() {
    _poleController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (StorageService.isLoggedIn) {
      if (StorageService.biometricEnabled) {
        final ok = await BiometricService.authenticate();
        if (!mounted) return;
        if (!ok) {
          setState(() => _biometricFailed = true);
          return;
        }
      }
      final user = StorageService.getUser();
      if (user?.role.name == 'barber') {
        Get.offAllNamed(Routes.ownerPanel);
      } else {
        Get.offAllNamed(Routes.main);
      }
    } else if (StorageService.onboardingSeen) {
      Get.offAllNamed(Routes.roleSelection);
    } else {
      setState(() => _showOnboarding = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) return const _OnboardingScreen();

    if (_biometricFailed) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, color: Colors.white54, size: 80),
                const SizedBox(height: 24),
                const Text('تأیید هویت ناموفق', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('لطفاً دوباره تلاش کنید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () { setState(() => _biometricFailed = false); _navigate(); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('تلاش دوباره', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async { await StorageService.logout(); Get.offAllNamed(Routes.roleSelection); },
                  child: const Text('ورود با رمز عبور', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: _BarberPoleWidget(controller: _poleController),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'آرایش پلاس',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'رزرو آسان، آرایش حرفه‌ای',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 15,
                  color: Colors.white60,
                ),
              ),
            ),
            const SizedBox(height: 60),
            FadeIn(
              delay: const Duration(milliseconds: 800),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarberPoleWidget extends StatelessWidget {
  final AnimationController controller;

  const _BarberPoleWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Transform.rotate(
          angle: controller.value * 2 * 3.14159,
          child: const Icon(Icons.content_cut, color: Colors.white, size: 48),
        ),
      ),
    );
  }
}

class _OnboardingScreen extends StatefulWidget {
  const _OnboardingScreen();

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      icon: Icons.search_rounded,
      title: 'جستجوی آسان',
      description: 'بهترین آرایشگاه‌های نزدیک خود را پیدا کنید و با یک کلیک مشاهده کنید',
      color: Color(0xFF1A1A2E),
    ),
    _OnboardingData(
      icon: Icons.calendar_month_rounded,
      title: 'رزرو سریع',
      description: 'نوبت خود را در هر زمان و مکانی به راحتی رزرو کنید. دیگر خبری از صف انتظار نیست',
      color: Color(0xFFE94560),
    ),
    _OnboardingData(
      icon: Icons.star_rounded,
      title: 'خدمات حرفه‌ای',
      description: 'با بهترین متخصصین آرایش در ایران ملاقات کنید و تجربه‌ای بی‌نظیر داشته باشید',
      color: Color(0xFF16213E),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            reverse: true,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _currentPage ? AppColors.secondary : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      if (_currentPage < _pages.length - 1) ...[
                        ElevatedButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          child: const Text(
                            'بعدی',
                            style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                              await StorageService.setOnboardingSeen();
                              Get.offAllNamed(Routes.roleSelection);
                            },
                          child: const Text(
                            'رد شدن',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await StorageService.setOnboardingSeen();
                              Get.offAllNamed(Routes.roleSelection);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'شروع کنید',
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [data.color, AppColors.primary],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: AppColors.secondary, size: 72),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              data.title,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
