import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  bool _emailSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendEmailReset() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  Future<void> _sendPhoneOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    Get.toNamed(Routes.phoneOtp, arguments: {
      'phone': _phoneCtrl.text.trim(),
      'purpose': 'forgot',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_reset, color: AppColors.secondary, size: 48),
                  const SizedBox(height: 14),
                  const Text(
                    'فراموشی رمز عبور',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'روش بازیابی رمز عبور را انتخاب کنید',
                    style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'ایمیل'),
                  Tab(text: 'شماره موبایل'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Email tab
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _emailSent
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'ایمیل ارسال شد!',
                                style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'لینک بازیابی به ${_emailCtrl.text} ارسال شد.\nصندوق ورودی خود را بررسی کنید.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60, height: 1.6),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.secondary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text(
                                    'بازگشت به ورود',
                                    style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.secondary, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Form(
                            key: _emailFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'آدرس ایمیل خود را وارد کنید تا لینک بازیابی برایتان ارسال شود.',
                                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60, height: 1.5),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.08),
                                    labelText: 'ایمیل',
                                    labelStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white60),
                                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
                                    errorStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.redAccent),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'ایمیل الزامی است';
                                    if (!v.contains('@')) return 'ایمیل نامعتبر است';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _sendEmailReset,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('ارسال لینک بازیابی', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Phone tab
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _phoneFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'شماره موبایل خود را وارد کنید تا کد تأیید برایتان ارسال شود.',
                            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              labelText: 'شماره موبایل',
                              labelStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white60),
                              prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white54),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
                              errorStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.redAccent),
                            ),
                            validator: (v) {
                              if (v == null || !RegExp(r'^09[0-9]{9}$').hasMatch(v.trim())) {
                                return 'شماره موبایل نامعتبر است';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sendPhoneOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('ارسال کد تأیید', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
