import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/user_model.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final List<TextEditingController> _ctls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _foci = List.generate(4, (_) => FocusNode());
  int _secondsLeft = 120;
  Timer? _timer;
  bool _verified = false;

  String get _phone => Get.arguments?['phone'] as String? ?? '';
  String get _purpose => Get.arguments?['purpose'] as String? ?? 'forgot';

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctls) c.dispose();
    for (final f in _foci) f.dispose();
    super.dispose();
  }

  void _sendOtp() {
    // ignore: avoid_print
    print('📱 OTP for $_phone: 1234');
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _foci[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  void _onDigit(int index, String val) {
    if (val.length == 1 && index < 3) {
      _foci[index + 1].requestFocus();
    }
    if (val.isEmpty && index > 0) {
      _foci[index - 1].requestFocus();
    }
    setState(() {});
    if (_ctls.every((c) => c.text.length == 1)) {
      _verify();
    }
  }

  void _verify() {
    final code = _ctls.map((c) => c.text).join();
    if (code == '1234') {
      setState(() => _verified = true);
      if (_purpose == 'forgot') {
        _handleForgotVerified();
      } else {
        Get.snackbar('موفق', 'کد تأیید صحیح بود', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        Future.delayed(const Duration(milliseconds: 400), () => Get.back(result: true));
      }
    } else {
      Get.snackbar('خطا', 'کد وارد شده اشتباه است', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      for (final c in _ctls) c.clear();
      setState(() => _verified = false);
      _foci[0].requestFocus();
    }
  }

  void _handleForgotVerified() {
    final registered = MockData.users.any((u) => u.phone == _phone);
    if (!registered) {
      setState(() => _verified = false);
      Get.snackbar(
        'شماره ثبت نشده',
        'شماره موبایل ثبت نشده است. لطفاً ثبت‌نام کنید.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      for (final c in _ctls) c.clear();
      _foci[0].requestFocus();
      return;
    }
    _showNewPasswordDialog();
  }

  void _showNewPasswordDialog() {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure1 = true;
    bool obscure2 = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('رمز عبور جدید', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: newPassCtrl,
                    obscureText: obscure1,
                    style: const TextStyle(fontFamily: 'Vazirmatn'),
                    decoration: InputDecoration(
                      labelText: 'رمز عبور جدید',
                      labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setLocal(() => obscure1 = !obscure1),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'حداقل ۶ کاراکتر' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: obscure2,
                    style: const TextStyle(fontFamily: 'Vazirmatn'),
                    decoration: InputDecoration(
                      labelText: 'تکرار رمز عبور',
                      labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setLocal(() => obscure2 = !obscure2),
                      ),
                    ),
                    validator: (v) => v != newPassCtrl.text ? 'رمزها یکسان نیستند' : null,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  // Update password in MockData
                  final idx = MockData.users.indexWhere((u) => u.phone == _phone);
                  if (idx != -1) {
                    final user = MockData.users[idx];
                    MockData.users[idx] = UserModel(
                      id: user.id,
                      fullName: user.fullName,
                      phone: user.phone,
                      email: user.email,
                      password: newPassCtrl.text,
                      role: user.role,
                      stylistStatus: user.stylistStatus,
                      createdAt: user.createdAt,
                    );
                  }
                  Navigator.pop(ctx);
                  Get.snackbar('موفق', 'رمز عبور با موفقیت تغییر یافت', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                  Future.delayed(const Duration(milliseconds: 600), () => Get.offAllNamed(Routes.roleSelection));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                child: const Text('ذخیره', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.sms_outlined, color: AppColors.secondary, size: 52),
              const SizedBox(height: 16),
              const Text(
                'کد تأیید',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60),
                  children: [
                    const TextSpan(text: 'کد ۴ رقمی ارسال شده به '),
                    TextSpan(
                      text: _phone.isNotEmpty ? _phone : 'شماره شما',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: ' را وارد کنید'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '(کد آزمایشی: ۱۲۳۴)',
                style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.white38),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Container(
                    width: 60,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _foci[i].hasFocus ? AppColors.secondary : Colors.white24,
                        width: _foci[i].hasFocus ? 1.5 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _ctls[i],
                      focusNode: _foci[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => _onDigit(i, v),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              if (!_verified)
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          'ارسال مجدد کد: $_timerText',
                          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white54),
                        )
                      : TextButton(
                          onPressed: () {
                            _startTimer();
                            _sendOtp();
                          },
                          child: const Text(
                            'ارسال مجدد کد',
                            style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.secondary, fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _ctls.every((c) => c.text.length == 1) ? _verify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'تأیید',
                    style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
