import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/persian_utils.dart';

class PersianCalendarPicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const PersianCalendarPicker({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<PersianCalendarPicker> createState() => _PersianCalendarPickerState();
}

class _PersianCalendarPickerState extends State<PersianCalendarPicker> {
  late Jalali _currentMonth;
  DateTime? _selectedDate;

  static const _weekDayLabels = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
  static const _monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    final now = Jalali.now();
    _currentMonth = Jalali(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth.month == 1) {
        _currentMonth = Jalali(_currentMonth.year - 1, 12);
      } else {
        _currentMonth = Jalali(_currentMonth.year, _currentMonth.month - 1);
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth.month == 12) {
        _currentMonth = Jalali(_currentMonth.year + 1, 1);
      } else {
        _currentMonth = Jalali(_currentMonth.year, _currentMonth.month + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _currentMonth.monthLength;
    final firstDay = Jalali(_currentMonth.year, _currentMonth.month, 1);
    // In Iran, Saturday=0, so shift weekday
    int firstWeekday = firstDay.toDateTime().weekday;
    // Map: Sat=6→0, Sun=7→1, Mon=1→2, Tue=2→3, Wed=3→4, Thu=4→5, Fri=5→6
    final dayOffset = {
      DateTime.saturday: 0,
      DateTime.sunday: 1,
      DateTime.monday: 2,
      DateTime.tuesday: 3,
      DateTime.wednesday: 4,
      DateTime.thursday: 5,
      DateTime.friday: 6,
    }[firstWeekday] ?? 0;

    final today = Jalali.now();
    final todayGregorian = today.toDateTime();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                  onPressed: _nextMonth,
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[_currentMonth.month - 1]} ${PersianUtils.toPersianDigits(_currentMonth.year.toString())}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                  onPressed: _prevMonth,
                ),
              ],
            ),
          ),
          // Week day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _weekDayLabels
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth + dayOffset,
              itemBuilder: (ctx, idx) {
                if (idx < dayOffset) return const SizedBox.shrink();
                final day = idx - dayOffset + 1;
                final jalaliDate = Jalali(_currentMonth.year, _currentMonth.month, day);
                final gregorianDate = jalaliDate.toDateTime();
                final isToday = jalaliDate.year == today.year &&
                    jalaliDate.month == today.month &&
                    jalaliDate.day == today.day;
                final isPast = gregorianDate.isBefore(
                  DateTime(todayGregorian.year, todayGregorian.month, todayGregorian.day),
                );
                final isSelected = _selectedDate != null &&
                    gregorianDate.year == _selectedDate!.year &&
                    gregorianDate.month == _selectedDate!.month &&
                    gregorianDate.day == _selectedDate!.day;

                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () {
                          setState(() => _selectedDate = gregorianDate);
                          widget.onDateSelected(gregorianDate);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary
                          : isToday
                              ? AppColors.secondary.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.secondary, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        PersianUtils.toPersianDigits(day.toString()),
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : isPast
                                  ? AppColors.textSecondary.withOpacity(0.4)
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
