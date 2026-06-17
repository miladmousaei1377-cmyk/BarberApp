import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/storage/data_service.dart';
import 'data/mock/mock_data.dart';
import 'data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  await DataService.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  MockData.init();
  MockData.onDataChanged = () => DataService.saveAll();
  DataService.loadAll();

  // Restore registered user so they can log in again after app restart.
  final storedUser = StorageService.getUser();
  if (storedUser != null && !MockData.users.any((u) => u.id == storedUser.id)) {
    MockData.users.add(storedUser);
    await DataService.saveAll();
  }

  runApp(const BarberBookApp());
}

class BarberBookApp extends StatelessWidget {
  const BarberBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'آرایش پلاس',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('fa', 'IR'),
      textDirection: TextDirection.rtl,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
