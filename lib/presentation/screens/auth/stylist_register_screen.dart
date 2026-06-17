import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class StylistRegisterScreen extends StatefulWidget {
  const StylistRegisterScreen({super.key});

  @override
  State<StylistRegisterScreen> createState() => _StylistRegisterScreenState();
}

class _StylistRegisterScreenState extends State<StylistRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _guildCodeCtrl = TextEditingController();
  final _salonNameCtrl = TextEditingController();
  final _salonAddressCtrl = TextEditingController();
  bool _obscure = true;
  late final AuthController _auth;
  final List<String> _uploadedDocs = [];

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
    _guildCodeCtrl.dispose();
    _salonNameCtrl.dispose();
    _salonAddressCtrl.dispose();
    super.dispose();
  }

  void _addDocument() {
    final docNames = ['پروانه کسب', 'کارت ملی', 'گواهینامه آرایشگری', 'مدرک فنی و حرفه‌ای'];
    setState(() {
      _uploadedDocs.add(docNames[_uploadedDocs.length % docNames.length]);
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.registerStylist(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      guildCode: _guildCodeCtrl.text.trim(),
      salonName: _salonNameCtrl.text.trim(),
      salonAddress: _salonAddressCtrl.text.trim(),
    );
    if (ok) Get.offAllNamed(Routes.pendingApproval);
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
                  'ثبت‌نام آرایشگر',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'اطلاعات خود را برای بررسی وارد کنید',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.white60),
                ),
                const SizedBox(height: 28),
                _SectionLabel(label: 'اطلاعات شخصی'),
                const SizedBox(height: 14),
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
                const SizedBox(height: 24),
                _SectionLabel(label: 'اطلاعات حرفه‌ای'),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _guildCodeCtrl,
                  label: 'کد صنفی / پروانه کسب',
                  icon: Icons.badge_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'کد صنفی الزامی است';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'مدارک و تصاویر'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'بارگذاری مدارک (اختیاری)',
                        style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.white60),
                      ),
                      const SizedBox(height: 10),
                      if (_uploadedDocs.isNotEmpty) ...[
                        ...List.generate(_uploadedDocs.length, (i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined, color: Colors.white54, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _uploadedDocs[i],
                                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.white70),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _uploadedDocs.removeAt(i)),
                                child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                      if (_uploadedDocs.length < 5)
                        GestureDetector(
                          onTap: _addDocument,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white30, style: BorderStyle.solid),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_outlined, color: Colors.white54, size: 20),
                                SizedBox(width: 8),
                                Text('افزودن مدرک', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: Colors.white54)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'اطلاعات آرایشگاه'),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _salonNameCtrl,
                  label: 'نام آرایشگاه',
                  icon: Icons.store_outlined,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) return 'نام آرایشگاه باید حداقل ۲ کاراکتر باشد';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _salonAddressCtrl,
                  label: 'آدرس آرایشگاه',
                  icon: Icons.location_on_outlined,
                  validator: (v) {
                    if (v == null || v.trim().length < 5) return 'آدرس باید حداقل ۵ کاراکتر باشد';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'پس از ثبت‌نام، اطلاعات شما توسط تیم آرایش پلاس بررسی می‌شود و ظرف ۲۴ ساعت نتیجه اعلام می‌گردد.',
                          style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.white60, height: 1.5),
                        ),
                      ),
                    ],
                  ),
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
                            'ارسال برای بررسی',
                            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white70)),
      ],
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
