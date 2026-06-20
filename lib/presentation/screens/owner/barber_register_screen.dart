import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../controllers/owner_controller.dart';
import '../../../core/services/neshan_service.dart';
import '../../../core/services/neshan_tile_provider.dart';
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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  SalonCategory _selectedCategory = SalonCategory.male;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isLoading = false;
  bool _geocoding = false;
  final List<XFile> _images = [];
  final _imagePicker = ImagePicker();
  bool _locationEnabled = false;
  double _lat = 35.7448;
  double _lng = 51.4100;
  final _previewMapController = MapController();


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _previewMapController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _images.add(picked));
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Get.toNamed(
      Routes.locationPicker,
      arguments: (_locationEnabled && _lat != 35.7448) ? LatLng(_lat, _lng) : null,
    );
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _locationEnabled = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try { _previewMapController.move(LatLng(_lat, _lng), 15); } catch (_) {}
      });
    }
  }

  Future<void> _geocodeAddress() async {
    if (_addressController.text.trim().isEmpty) return;
    setState(() => _geocoding = true);
    final ll = await NeshanService.geocodeAddress(_addressController.text);
    if (!mounted) return;
    setState(() => _geocoding = false);
    if (ll != null) {
      setState(() {
        _lat = ll.latitude;
        _lng = ll.longitude;
        _locationEnabled = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try { _previewMapController.move(LatLng(_lat, _lng), 15); } catch (_) {}
      });
    } else {
      Get.snackbar(
        'آدرس یافت نشد',
        'لطفاً آدرس دقیق‌تری وارد کنید یا موقعیت را دستی انتخاب کنید',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
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
          ? 'آرایشگاه ${_nameController.text.trim()}'
          : _descController.text.trim(),
      address: _addressController.text.trim(),
      lat: _locationEnabled ? _lat : 0.0,
      lng: _locationEnabled ? _lng : 0.0,
      rating: 5.0,
      reviewCount: 0,
      isVerified: false,
      category: _selectedCategory,
      ownerId: user?.id ?? 'unknown',
      images: _images.map((x) => x.path).toList(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      openTime: _formatTime(_startTime),
      closeTime: _formatTime(_endTime),
    );

    OwnerController.to.registerSalon(salon);
    setState(() => _isLoading = false);

    if (!mounted) return;
    final addServices = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 10),
              const Text('آرایشگاه ثبت شد!', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: const Text(
            'آیا می‌خواهید الان خدمات آرایشگاه خود را اضافه کنید؟',
            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('بعداً', style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('افزودن خدمات', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    Get.back(result: addServices == true ? 'addServices' : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ثبت آرایشگاه'),
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
                labelText: 'نام آرایشگاه',
                labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                prefixIcon: const Icon(Icons.store_outlined, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 2) {
                  return 'نام آرایشگاه باید حداقل ۲ کاراکتر باشد';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Phone
            TextFormField(
              controller: _phoneController,
              textDirection: TextDirection.rtl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15),
              decoration: InputDecoration(
                labelText: 'شماره تلفن (اختیاری)',
                labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                suffixIcon: _geocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search_outlined, color: AppColors.primary),
                        tooltip: 'یافتن موقعیت از آدرس',
                        onPressed: _geocodeAddress,
                      ),
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
              'دسته‌بندی آرایشگاه',
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
            const SizedBox(height: 20),
            // Location section — always accessible
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'موقعیت مکانی',
                        style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const Text(
                        'اختیاری',
                        style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _locationEnabled,
                  onChanged: (v) => setState(() => _locationEnabled = v),
                  activeColor: AppColors.secondary,
                ),
              ],
            ),
            // Pick location button always visible
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (!_locationEnabled) setState(() => _locationEnabled = true);
                  await _pickLocation();
                },
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: Text(
                  _locationEnabled ? 'ویرایش موقعیت روی نقشه' : 'انتخاب موقعیت روی نقشه',
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            if (_locationEnabled) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: FlutterMap(
                    mapController: _previewMapController,
                    options: MapOptions(
                      initialCenter: LatLng(_lat, _lng),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      const NeshanTileLayer(),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_lat, _lng),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.teal, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    'موقعیت انتخاب شد: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                    style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.teal),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            // Images section
            const Text(
              'تصاویر آرایشگاه',
              style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...List.generate(_images.length, (i) => Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(File(_images[i].path), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(i)),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (_images.length < 5)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppColors.textSecondary, size: 28),
                            SizedBox(height: 4),
                            Text('افزودن', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                ],
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
                        'ثبت آرایشگاه',
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
