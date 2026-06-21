import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/user_model.dart';

class _MockNotif {
  final String title;
  final String body;
  final String time;
  bool isRead;

  _MockNotif({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}

final _customerNotifs = [
  _MockNotif(title: 'رزرو تأیید شد', body: 'نوبت شما با موفقیت ثبت و تأیید شد.', time: 'امروز ۱۰:۳۰', isRead: false),
  _MockNotif(title: 'یادآوری نوبت', body: 'نوبت شما فردا ساعت ۱۰ است. فراموش نکنید!', time: 'امروز ۰۹:۰۰', isRead: false),
  _MockNotif(title: 'تخفیف ویژه', body: 'تخفیف ۲۰٪ برای اولین رزرو فعال شد.', time: 'دیروز ۱۲:۰۰', isRead: true),
  _MockNotif(title: 'امتیاز دریافت شد', body: 'آرایشگاه خاص ۴ ستاره به شما امتیاز داد.', time: 'دیروز ۱۸:۱۵', isRead: true),
  _MockNotif(title: 'خوش آمدید', body: 'خوش آمدید به BarberBook. رزرو آنلاین را تجربه کنید!', time: '۳ روز پیش', isRead: true),
];

final _barberNotifs = [
  _MockNotif(title: 'نوبت جدید', body: 'علی رضایی یک نوبت برای فردا ساعت ۱۱ رزرو کرد.', time: 'امروز ۱۱:۰۰', isRead: false),
  _MockNotif(title: 'لغو نوبت', body: 'نوبت ساعت ۱۴:۰۰ امروز توسط مشتری لغو شد.', time: 'امروز ۱۰:۳۰', isRead: false),
  _MockNotif(title: 'امتیاز جدید', body: 'مشتری جدید ۵ ستاره به آرایشگاه شما داد.', time: 'دیروز ۱۷:۴۵', isRead: true),
  _MockNotif(title: 'یادآوری نوبت‌ها', body: 'امروز ۳ نوبت فعال دارید. برنامه روز را مرور کنید.', time: 'دیروز ۰۸:۰۰', isRead: true),
  _MockNotif(title: 'پروفایل تأیید شد', body: 'پروفایل آرایشگاه شما با موفقیت تأیید و منتشر شد.', time: '۲ روز پیش', isRead: true),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsScreen> {
  late List<_MockNotif> _notifications;

  @override
  void initState() {
    super.initState();
    final role = StorageService.getUser()?.role;
    // Deep-copy so edits don't persist across navigations
    final source = role == UserRole.barber ? _barberNotifs : _customerNotifs;
    _notifications = source
        .map((n) => _MockNotif(title: n.title, body: n.body, time: n.time, isRead: n.isRead))
        .toList();
  }

  bool get _hasUnread => _notifications.any((n) => !n.isRead);

  void _markAllRead() => setState(() {
        for (final n in _notifications) n.isRead = true;
      });

  void _markRead(int i) {
    if (!_notifications[i].isRead) setState(() => _notifications[i].isRead = true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'اعلان‌ها',
            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          actions: _hasUnread
              ? [
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text('خواندن همه',
                        style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white, fontSize: 14)),
                  ),
                ]
              : null,
        ),
        body: _notifications.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  if (!_hasUnread) _buildAllReadBanner(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) => _buildCard(i),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 72, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('اعلانی وجود ندارد',
              style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAllReadBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F0F0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Text(
        'همه اعلان‌ها خوانده شده',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildCard(int index) {
    final n = _notifications[index];
    final unread = !n.isRead;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: unread ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: unread ? const Color(0xFF0F3460) : Colors.grey.shade300,
          child: Icon(Icons.notifications_outlined,
              color: unread ? Colors.white : Colors.grey.shade600, size: 20),
        ),
        title: Text(
          n.title,
          style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14,
              fontWeight: unread ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n.body,
                  style: const TextStyle(
                      fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(n.time,
                  style: const TextStyle(
                      fontFamily: 'Vazirmatn', fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        trailing: unread
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              )
            : null,
        onTap: () => _markRead(index),
      ),
    );
  }
}
