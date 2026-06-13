import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/persian_utils.dart';

enum SlotStatus { available, taken, past, selected }

class TimeSlotChip extends StatelessWidget {
  final String time;
  final SlotStatus status;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.time,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelectable = status == SlotStatus.available || status == SlotStatus.selected;

    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (status) {
      case SlotStatus.selected:
        bgColor = AppColors.secondary;
        textColor = Colors.white;
        borderColor = AppColors.secondary;
        break;
      case SlotStatus.available:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        borderColor = AppColors.success;
        break;
      case SlotStatus.taken:
        bgColor = AppColors.error.withOpacity(0.08);
        textColor = AppColors.error.withOpacity(0.5);
        borderColor = AppColors.error.withOpacity(0.3);
        break;
      case SlotStatus.past:
        bgColor = AppColors.divider;
        textColor = AppColors.textSecondary;
        borderColor = AppColors.divider;
        break;
    }

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          PersianUtils.formatTime(time),
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
