import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsScreen> {
  final List<_MockNotif> _notifications = [
    _MockNotif(
      title: 'رزرو تأیید شد',
      body: 'نوبت شما با موفقیت ثبت و تأیید شد.',
      time: 'امروز ۱۰:۳۰',
      isRead: false,
    ),
    _MockNotif(
      title: 'یادآوری نوبت',
      body: 'نوبت شما فردا ساعت ۱۰ است.',
      time: 'امروز ۰۹:۰۰',
      isRead: false,
    ),
    _MockNotif(
      title: 'امتیاز دریافت شد',
      body: 'آرایشگاه خاص ۴ ستاره به شما امتیاز داد.',
      time: 'دیروز ۱۸:۱۵',
      isRead: true,
    ),
    _MockNotif(
      title: 'تخفیف ویژه',
      body: 'تخفیف ویژه وارد شد. همین حالا استفاده کنید!',
      time: 'دیروز ۱۲:۰۰',
      isRead: true,
    ),
    _MockNotif(
      title: 'خوش آمدید',
      body: 'خوش آمدید به BarberBook.',
      time: '۳ روز پیش',
      isRead: true,
    ),
  ];

  bool get _hasUnread => _notifications.any((n) => !n.isRead);

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(int index) {
    if (!_notifications[index].isRead) {
      setState(() {
        _notifications[index].isRead = true;
      });
    }
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
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: _hasUnread
              ? [
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text(
                      'خواندن همه',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        return _buildNotifCard(index);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.notifications_off_outlined,
            size: 72,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'اعلانی وجود ندارد',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
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
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNotifCard(int index) {
    final notif = _notifications[index];
    final bool unread = !notif.isRead;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: unread ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          backgroundColor:
              unread ? const Color(0xFF0F3460) : Colors.grey.shade300,
          child: Icon(
            Icons.notifications_outlined,
            color: unread ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 14,
            fontWeight: unread ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notif.body,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notif.time,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        trailing: unread
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _markRead(index),
      ),
    );
  }
}
