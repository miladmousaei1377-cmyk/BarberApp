import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/mock/mock_data.dart';

class StylistLoginScreen extends StatefulWidget {
  const StylistLoginScreen({super.key});

  @override
  State<StylistLoginScreen> createState() => _StylistLoginScreenState();
}

class _StylistLoginScreenState extends State<StylistLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _biometricAvailable = false;
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.put(AuthController());
    _auth.clearError();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    if (!StorageService.biometricEnabled) return;
    final avail = await BiometricService.isAvailable();
    if (mounted) setState(() => _biometricAvailable = avail);
  }

  Future<void> _loginWithBiometric() async {
    final ok = await BiometricService.authenticate();
    if (!ok || !mounted) return;
    final userId = StorageService.biometricUserId;
    if (userId == null) {
      Get.snackbar('توجه', 'لطفاً ابتدا با رمز عبور وارد شوید',
          backgroundColor: AppColors.secondary.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final user = MockData.users.firstWhere((u) => u.id == userId);
      await StorageService.saveToken('bio_${user.id}');
      await StorageService.saveUser(user);
      Get.offAllNamed(Routes.ownerPanel);
    } catch (_) {
      Get.snackbar('خطا', 'اطلاعات کاربری یافت نشد. لطفاً با رمز عبور وارد شوید.',
          backgroundColor: AppColors.secondary.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _auth.clearError();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await _auth.loginStylist(
      emailOrPhone: _loginCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    switch (result) {
      case StylistLoginResult.success:
        Get.offAllNamed(Routes.ownerPanel);
        break;
      case StylistLoginResult.pending:
        Get.offAllNamed(Routes.pendingApproval);
        break;
      case StylistLoginResult.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.content_cut, color: AppColors.secondary, size: 52),
                const SizedBox(height: 16),
                const Text(
                  'ورود آرایشگر',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'به پنل مدیریت آرایشگاه خوش آمدید',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60),
                ),
                const SizedBox(height: 40),
                _AuthField(
                  controller: _loginCtrl,
                  label: 'ایمیل یا شماره موبایل',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'ایمیل یا شماره موبایل الزامی است';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _AuthField(
                  controller: _passwordCtrl,
                  label: 'رمز عبور',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.white60,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.forgotPassword),
                    child: const Text(
                      'فراموشی رمز عبور؟',
                      style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (_auth.errorMsg.value.isEmpty) return const SizedBox();
                  return Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _auth.errorMsg.value,
                      style: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.redAccent, fontSize: 13),
                    ),
                  );
                }),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _auth.isLoading.value ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _auth.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'ورود',
                            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                )),
                if (_biometricAvailable) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _loginWithBiometric,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.fingerprint, color: AppColors.secondary, size: 52),
                          SizedBox(height: 6),
                          Text(
                            'ورود با اثر انگشت',
                            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('یا', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white38)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'آرایشگر جدید هستید؟',
                      style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white60),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.stylistRegister),
                      child: const Text(
                        'ثبت‌نام کنید',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        errorStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}
