import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/persian_utils.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _submit() async {
    final phone = _phoneController.text.trim();
    if (!PersianUtils.isValidIranPhone(phone)) {
      setState(() => _error = 'شماره موبایل وارد شده معتبر نیست');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    Get.toNamed(Routes.otp, arguments: phone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.content_cut, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 32),
              FadeInRight(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  'ورود به آراپوینت',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInRight(
                delay: const Duration(milliseconds: 300),
                child: const Text(
                  'شماره موبایل خود را وارد کنید تا کد تأیید ارسال شود',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '09xxxxxxxxx',
                    hintStyle: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                    errorText: _error,
                    prefixIcon: const Icon(Icons.phone_android_outlined, color: AppColors.textSecondary),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 32),
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
                        : const Text('ارسال کد تأیید'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Center(
                  child: Text(
                    'با ورود، قوانین و مقررات آراپوینت را می‌پذیرید',
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
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
