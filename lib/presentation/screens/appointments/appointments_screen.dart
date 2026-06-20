import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/data_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/appointment_model.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentModel> _getAppointments(String filter) {
    final user = StorageService.getUser();
    if (user == null) return [];

    final all = MockData.getAppointmentsByUser(user.id);
    final now = DateTime.now();

    switch (filter) {
      case 'upcoming':
        return all.where((a) {
          final apt = DateTime(a.date.year, a.date.month, a.date.day,
              int.parse(a.startTime.split(':')[0]), int.parse(a.startTime.split(':')[1]));
          return apt.isAfter(now) &&
              (a.status == AppointmentStatus.pending ||
                  a.status == AppointmentStatus.confirmed);
        }).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      case 'past':
        return all
            .where((a) =>
                a.status == AppointmentStatus.done ||
                DateTime(a.date.year, a.date.month, a.date.day).isBefore(
                    DateTime(now.year, now.month, now.day)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      case 'cancelled':
        return all.where((a) => a.status == AppointmentStatus.cancelled).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      default:
        return [];
    }
  }

  void _cancelAppointment(String id) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'لغو رزرو',
              style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'آیا مطمئن هستید که می‌خواهید این رزرو را لغو کنید؟',
                  style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonCtrl,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'دلیل لغو (اختیاری)',
                    hintStyle: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  MockData.cancelAppointment(id, reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim());
                  Navigator.of(ctx).pop();
                  setState(() {});
                  Get.snackbar('موفق', 'رزرو با موفقیت لغو شد',
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('لغو رزرو', style: TextStyle(fontFamily: 'Vazirmatn')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(AppointmentModel appointment) {
    int rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ثبت نظر',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setInner(() => rating = i + 1),
                      child: Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.gold,
                        size: 40,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'نظر خود را بنویسید...',
                  labelText: 'نظر',
                  labelStyle: TextStyle(fontFamily: 'Vazirmatn'),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontFamily: 'Vazirmatn'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.snackbar('موفق', 'نظر شما ثبت شد',
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  child: const Text('ثبت نظر', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رزروهای من', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.ownerBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
          tabs: const [
            Tab(text: 'آینده'),
            Tab(text: 'گذشته'),
            Tab(text: 'لغو شده'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentList(
            appointments: _getAppointments('upcoming'),
            emptyMessage: 'رزرو آینده‌ای ندارید',
            onCancel: _cancelAppointment,
            allowMultiSelect: false,
            onRefresh: () => setState(() {}),
          ),
          _AppointmentList(
            appointments: _getAppointments('past'),
            emptyMessage: 'رزروی در گذشته ندارید',
            onReview: _showReviewDialog,
            allowMultiSelect: true,
            onRefresh: () => setState(() {}),
          ),
          _AppointmentList(
            appointments: _getAppointments('cancelled'),
            emptyMessage: 'رزرو لغو شده‌ای ندارید',
            allowMultiSelect: true,
            onRefresh: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}

class _AppointmentList extends StatefulWidget {
  final List<AppointmentModel> appointments;
  final String emptyMessage;
  final Function(String)? onCancel;
  final Function(AppointmentModel)? onReview;
  final bool allowMultiSelect;
  final VoidCallback? onRefresh;

  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
    this.onCancel,
    this.onReview,
    this.allowMultiSelect = false,
    this.onRefresh,
  });

  @override
  State<_AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<_AppointmentList> {
  bool _selecting = false;
  final Set<String> _selected = {};

  void _enterSelectMode() => setState(() { _selecting = true; _selected.clear(); });
  void _exitSelectMode() => setState(() { _selecting = false; _selected.clear(); });

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف رزروها', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
          content: Text('آیا ${PersianUtils.toPersianDigits(count.toString())} رزرو انتخاب‌شده حذف شود؟', style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('حذف', style: TextStyle(fontFamily: 'Vazirmatn')),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final ids = List<String>.from(_selected);
    for (final id in ids) MockData.deleteAppointment(id);
    DataService.saveAll();
    Get.snackbar('حذف شد', '${PersianUtils.toPersianDigits(count.toString())} رزرو حذف شد', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    _exitSelectMode();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final apts = widget.appointments;
    if (apts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final allSelected = apts.every((a) => _selected.contains(a.id));

    return Column(
      children: [
        if (widget.allowMultiSelect)
          if (_selecting)
            Container(
              color: AppColors.ownerBlue.withOpacity(0.07),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: allSelected,
                    activeColor: AppColors.ownerBlue,
                    onChanged: (v) => setState(() {
                      if (v == true) _selected.addAll(apts.map((a) => a.id));
                      else _selected.clear();
                    }),
                  ),
                  Text(
                    allSelected ? 'لغو انتخاب همه' : 'انتخاب همه',
                    style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.ownerBlue),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _exitSelectMode,
                    child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary)),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _enterSelectMode,
                  icon: const Icon(Icons.checklist_outlined, size: 18),
                  label: const Text('انتخاب چندتایی', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.ownerBlue),
                ),
              ),
            ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: apts.length,
            itemBuilder: (_, i) {
              final apt = apts[i];
              if (_selecting) {
                final isSelected = _selected.contains(apt.id);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) _selected.remove(apt.id); else _selected.add(apt.id);
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.ownerBlue : Colors.transparent, width: 2),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: AppColors.ownerBlue,
                          onChanged: (v) => setState(() {
                            if (v == true) _selected.add(apt.id); else _selected.remove(apt.id);
                          }),
                        ),
                        Expanded(
                          child: AppointmentCard(appointment: apt),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Dismissible(
                key: Key(apt.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                confirmDismiss: (_) => showDialog<bool>(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('حذف رزرو', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                      content: const Text('این رزرو از تاریخچه شما حذف می‌شود. آیا مطمئن هستید؟', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary))),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('حذف', style: TextStyle(fontFamily: 'Vazirmatn')),
                        ),
                      ],
                    ),
                  ),
                ),
                onDismissed: (_) {
                  MockData.deleteAppointment(apt.id);
                  DataService.saveAll();
                  widget.onRefresh?.call();
                  Get.snackbar('حذف شد', 'رزرو از تاریخچه شما حذف شد', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                },
                child: AppointmentCard(
                  appointment: apt,
                  onCancel: widget.onCancel != null ? () => widget.onCancel!(apt.id) : null,
                  onReview: widget.onReview != null ? () => widget.onReview!(apt) : null,
                ),
              );
            },
          ),
        ),
        if (_selecting)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: ElevatedButton.icon(
              onPressed: _selected.isEmpty ? null : _deleteSelected,
              icon: const Icon(Icons.delete_outline),
              label: Text(
                _selected.isEmpty ? 'رزروی انتخاب نشده' : 'حذف ${PersianUtils.toPersianDigits(_selected.length.toString())} رزرو',
                style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }
}
