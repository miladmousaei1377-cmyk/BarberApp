import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/salon_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/stylist_model.dart';
import '../../widgets/service_tile.dart';
import '../../widgets/time_slot_chip.dart';
import '../../widgets/persian_calendar_picker.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late SalonModel _salon;
  int _currentStep = 0;

  // Step 1
  final Set<String> _selectedServiceIds = {};
  String? _selectedStylistId;

  // Step 2
  DateTime? _selectedDate;
  String? _selectedSlot;

  // Step 3
  final _notesController = TextEditingController();
  bool _isBooking = false;

  List<ServiceModel> get _services => MockData.getServicesBySalon(_salon.id);
  List<StylistModel> get _stylists => MockData.getStylistsBySalon(_salon.id);

  List<ServiceModel> get _selectedServices =>
      _services.where((s) => _selectedServiceIds.contains(s.id)).toList();

  int get _totalPrice => _selectedServices.fold(0, (sum, s) => sum + s.price);

  int get _totalDuration =>
      _selectedServices.fold(0, (sum, s) => sum + s.durationMinutes);

  List<String> get _availableSlots {
    if (_selectedDate == null) return [];
    return MockData.getAvailableSlots(
      _salon.id,
      _selectedStylistId,
      _selectedDate!,
      _totalDuration == 0 ? 30 : _totalDuration,
    );
  }

  @override
  void initState() {
    super.initState();
    _salon = Get.arguments as SalonModel;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedServiceIds.isEmpty) {
      Get.snackbar('خطا', 'لطفاً حداقل یک خدمت انتخاب کنید',
          backgroundColor: AppColors.error, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_currentStep == 1 && (_selectedDate == null || _selectedSlot == null)) {
      Get.snackbar('خطا', 'لطفاً تاریخ و ساعت را انتخاب کنید',
          backgroundColor: AppColors.error, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _confirmBooking();
    }
  }

  Future<void> _confirmBooking() async {
    final user = StorageService.getUser();
    if (user == null) return;

    setState(() => _isBooking = true);
    await Future.delayed(const Duration(seconds: 1));

    final selectedStylist = _selectedStylistId != null
        ? _stylists.firstWhereOrNull((s) => s.id == _selectedStylistId)
        : null;
    final endTime = _addMinutes(_selectedSlot!, _totalDuration);

    final appointment = AppointmentModel(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      salonId: _salon.id,
      salonName: _salon.name,
      salonAddress: _salon.address,
      stylistId: selectedStylist?.id,
      stylistName: selectedStylist?.name,
      serviceIds: _selectedServiceIds.toList(),
      serviceNames: _selectedServices.map((s) => s.name).toList(),
      date: _selectedDate!,
      startTime: _selectedSlot!,
      endTime: endTime,
      status: AppointmentStatus.confirmed,
      totalPrice: _totalPrice,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    MockData.addAppointment(appointment);
    setState(() => _isBooking = false);
    Get.offAllNamed(Routes.bookingSuccess, arguments: appointment);
  }

  String _addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final totalMins = int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes;
    return '${(totalMins ~/ 60).toString().padLeft(2, '0')}:${(totalMins % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رزرو نوبت'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => _currentStep > 0 ? setState(() => _currentStep--) : Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
            ][_currentStep],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['خدمات', 'زمان', 'تأیید'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx < _currentStep ? AppColors.secondary : AppColors.divider,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isDone = stepIdx < _currentStep;
          final isActive = stepIdx == _currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone || isActive ? AppColors.secondary : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Center(
                        child: Text(
                          PersianUtils.toPersianDigits((stepIdx + 1).toString()),
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx],
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.secondary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text(
                'خدمات',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${PersianUtils.toPersianDigits(_selectedServiceIds.length.toString())} انتخاب شده',
                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: _services.length,
            itemBuilder: (_, i) {
              final s = _services[i];
              return ServiceTile(
                service: s,
                isSelected: _selectedServiceIds.contains(s.id),
                showCheckbox: true,
                onTap: () => setState(() {
                  if (_selectedServiceIds.contains(s.id)) {
                    _selectedServiceIds.remove(s.id);
                  } else {
                    _selectedServiceIds.add(s.id);
                  }
                  _selectedSlot = null;
                }),
              );
            },
          ),
        ),
        if (_stylists.isNotEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Text(
                  'انتخاب آرایشگر (اختیاری)',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_selectedStylistId != null)
                  TextButton(
                    onPressed: () => setState(() => _selectedStylistId = null),
                    child: const Text('حذف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.error, fontSize: 12)),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: _stylists.length,
              itemBuilder: (_, i) {
                final st = _stylists[i];
                final isSelected = _selectedStylistId == st.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStylistId = isSelected ? null : st.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              st.name.characters.first,
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          st.name.split(' ').first,
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    final slots = _availableSlots;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PersianCalendarPicker(
          selectedDate: _selectedDate,
          onDateSelected: (d) => setState(() {
            _selectedDate = d;
            _selectedSlot = null;
          }),
        ),
        if (_selectedDate != null) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'ساعت‌های موجود',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_totalDuration > 0)
                Text(
                  'مدت: ${PersianUtils.toPersianDigits(_totalDuration.toString())} دقیقه',
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (slots.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'ظرفیت این روز پر است\nروز دیگری انتخاب کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Wrap(
              children: slots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return TimeSlotChip(
                  time: slot,
                  status: isSelected ? SlotStatus.selected : SlotStatus.available,
                  onTap: () => setState(() => _selectedSlot = slot),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SlotLegend(color: AppColors.success, label: 'آزاد'),
              const SizedBox(width: 16),
              _SlotLegend(color: AppColors.error, label: 'رزرو شده'),
              const SizedBox(width: 16),
              _SlotLegend(color: AppColors.secondary, label: 'انتخاب شده'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    final stylist = _selectedStylistId != null
        ? _stylists.firstWhereOrNull((s) => s.id == _selectedStylistId)
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'خلاصه رزرو',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow(Icons.store_outlined, 'سالن', _salon.name),
                    if (stylist != null)
                      _SummaryRow(Icons.person_outline, 'آرایشگر', stylist.name),
                    _SummaryRow(
                      Icons.calendar_today_outlined,
                      'تاریخ',
                      _selectedDate != null ? PersianUtils.gregorianToJalali(_selectedDate!) : '-',
                    ),
                    _SummaryRow(
                      Icons.access_time,
                      'ساعت',
                      _selectedSlot != null
                          ? '${PersianUtils.formatTime(_selectedSlot!)} - ${PersianUtils.formatTime(_addMinutes(_selectedSlot!, _totalDuration))}'
                          : '-',
                    ),
                    const Divider(color: AppColors.divider),
                    ..._selectedServices.map((s) => _SummaryRow(
                          Icons.cut_outlined,
                          s.name,
                          '${PersianUtils.toPersianDigits(s.durationMinutes.toString())} دقیقه',
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          textDirection: TextDirection.rtl,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'یادداشت برای آرایشگاه (اختیاری)...',
            labelText: 'یادداشت',
            labelStyle: TextStyle(fontFamily: 'Vazirmatn'),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedServiceIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${PersianUtils.toPersianDigits(_selectedServiceIds.length.toString())} خدمت انتخاب شده',
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'مدت: ${PersianUtils.toPersianDigits(_totalDuration.toString())} دقیقه',
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _nextStep,
              child: _isBooking
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _currentStep == 2 ? 'تأیید و رزرو' : 'مرحله بعد',
                      style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPrice;

  const _SummaryRow(this.icon, this.label, this.value, {this.isPrice = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: isPrice ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _SlotLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
