import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>() is AuthController
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.registerCustomer(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (ok) Get.offAllNamed(Routes.main);
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
                const SizedBox(height: 20),
                const Text(
                  'ثبت‌نام مشتری',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'یک حساب کاربری رایگان بسازید',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60),
                ),
                const SizedBox(height: 36),
                _AuthField(
                  controller: _nameCtrl,
                  label: 'نام و نام خانوادگی',
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().length < 3) return 'نام باید حداقل ۳ کاراکتر باشد';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _phoneCtrl,
                  label: 'شماره موبایل',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || !RegExp(r'^09[0-9]{9}$').hasMatch(v.trim())) {
                      return 'شماره موبایل نامعتبر است';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _emailCtrl,
                  label: 'ایمیل',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'ایمیل الزامی است';
                    if (!v.contains('@')) return 'ایمیل نامعتبر است';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                _AuthField(
                  controller: _confirmCtrl,
                  label: 'تکرار رمز عبور',
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.white60,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'رمز عبور مطابقت ندارد';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                    onPressed: _auth.isLoading.value ? null : _register,
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
                            'ثبت‌نام',
                            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'قبلاً ثبت‌نام کرده‌اید؟',
                      style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white60),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'وارد شوید',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
