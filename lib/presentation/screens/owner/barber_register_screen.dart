import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../controllers/owner_controller.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/salon_model.dart';

class BarberRegisterScreen extends StatefulWidget {
  const BarberRegisterScreen({super.key});

  @override
  State<BarberRegisterScreen> createState() => _BarberRegisterScreenState();
}

class _BarberRegisterScreenState extends State<BarberRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  SalonCategory _selectedCategory = SalonCategory.male;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final user = StorageService.getUser();
    final salon = SalonModel(
      id: 'salon_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'سالن ${_nameController.text.trim()}'
          : _descController.text.trim(),
      address: _addressController.text.trim(),
      lat: 35.7448,
      lng: 51.4100,
      rating: 5.0,
      reviewCount: 0,
      isVerified: false,
      category: _selectedCategory,
      ownerId: user?.id ?? 'unknown',
      images: const [],
    );

    OwnerController.to.registerSalon(salon);
    setState(() => _isLoading = false);

    Get.back();
    Get.snackbar(
      'موفق',
      'سالن "${salon.name}" با موفقیت ثبت شد',
      backgroundColor: const Color(0xFF28A745),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ثبت سالن'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            // Salon name
            TextFormField(
              controller: _nameController,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15),
              decoration: InputDecoration(
                labelText: 'نام سالن',
                labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                prefixIcon: const Icon(Icons.store_outlined, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 2) {
                  return 'نام سالن باید حداقل ۲ کاراکتر باشد';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Address
            TextFormField(
              controller: _addressController,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15),
              decoration: InputDecoration(
                labelText: 'آدرس',
                labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 5) {
                  return 'آدرس باید حداقل ۵ کاراکتر باشد';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Category
            const Text(
              'دسته‌بندی سالن',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _CategoryOption(
                  label: 'مردانه',
                  icon: Icons.man_outlined,
                  isSelected: _selectedCategory == SalonCategory.male,
                  onTap: () => setState(() => _selectedCategory = SalonCategory.male),
                ),
                const SizedBox(width: 12),
                _CategoryOption(
                  label: 'زنانه',
                  icon: Icons.woman_outlined,
                  isSelected: _selectedCategory == SalonCategory.female,
                  onTap: () => setState(() => _selectedCategory = SalonCategory.female),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Working hours
            const Text(
              'ساعت کاری',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(isStart: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_startTime),
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'تا',
                    style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(isStart: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.nights_stay_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_endTime),
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descController,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15),
              decoration: InputDecoration(
                labelText: 'توضیحات (اختیاری)',
                alignLabelWithHint: true,
                labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_outlined, color: AppColors.textSecondary),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'ثبت سالن',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
