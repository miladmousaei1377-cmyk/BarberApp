import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/user_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'نام باید حداقل ۲ کاراکتر باشد');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Arguments can be a Map with phone and role, or just a phone String
    final args = Get.arguments;
    String phone = '09000000000';
    UserRole role = UserRole.customer;

    if (args is Map) {
      phone = (args['phone'] as String?) ?? '09000000000';
      final roleStr = (args['role'] as String?) ?? 'customer';
      role = UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.customer,
      );
    } else if (args is String) {
      phone = args;
    }

    final user = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      phone: phone,
      fullName: name,
      role: role,
      createdAt: DateTime.now(),
    );

    await StorageService.saveUser(user);
    await StorageService.saveToken('mock_jwt_token_${user.id}');

    Get.offAllNamed(Routes.main);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider, width: 2),
                        ),
                        child: const Icon(Icons.person, size: 56, color: AppColors.textSecondary),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInRight(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  'پروفایل خود را بسازید',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInRight(
                delay: const Duration(milliseconds: 300),
                child: const Text(
                  'نام کامل خود را وارد کنید',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: TextField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    errorText: _error,
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('ورود به برنامه'),
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
