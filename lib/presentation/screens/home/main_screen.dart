import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../appointments/appointments_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../owner/barber_panel_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = Get.arguments;
      if (arg is int && arg >= 0 && arg < 4) {
        setState(() => _currentIndex = arg);
      }
    });
  }

  static const _screens = [
    HomeScreen(),
    AppointmentsScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'خروج از برنامه',
            style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'آیا می‌خواهید از برنامه خارج شوید؟',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('خیر', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('خروج', style: TextStyle(fontFamily: 'Vazirmatn')),
            ),
          ],
        ),
      ),
    );
    if (exit == true) {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();
    final isBarber = user?.role == UserRole.barber;

    if (isBarber) {
      return const BarberPanelScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _onWillPop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}
