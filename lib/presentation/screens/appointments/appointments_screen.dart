import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'لغو رزرو',
          style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این رزرو را لغو کنید؟',
          style: TextStyle(fontFamily: 'Vazirmatn'),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              MockData.cancelAppointment(id);
              Get.back();
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
        title: const Text('رزروهای من'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
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
          ),
          _AppointmentList(
            appointments: _getAppointments('past'),
            emptyMessage: 'رزروی در گذشته ندارید',
            onReview: _showReviewDialog,
          ),
          _AppointmentList(
            appointments: _getAppointments('cancelled'),
            emptyMessage: 'رزرو لغو شده‌ای ندارید',
          ),
        ],
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyMessage;
  final Function(String)? onCancel;
  final Function(AppointmentModel)? onReview;

  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
    this.onCancel,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: appointments.length,
      itemBuilder: (_, i) => AppointmentCard(
        appointment: appointments[i],
        onCancel: onCancel != null ? () => onCancel!(appointments[i].id) : null,
        onReview: onReview != null ? () => onReview!(appointments[i]) : null,
      ),
    );
  }
}
