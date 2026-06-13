import 'package:shamsi_date/shamsi_date.dart';

class PersianUtils {
  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  static const _persianMonths = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];
  static const _persianWeekDays = [
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'
  ];

  static String toPersianDigits(String input) {
    var result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(i.toString(), _persianDigits[i]);
    }
    return result;
  }

  static String formatPrice(int price) {
    final formatted = _addThousandSeparator(price.toString());
    return '${toPersianDigits(formatted)} تومان';
  }

  static String formatPriceShort(int price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      return '${toPersianDigits(millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1))} میلیون تومان';
    }
    if (price >= 1000) {
      final thousands = price ~/ 1000;
      return '${toPersianDigits(thousands.toString())} هزار تومان';
    }
    return formatPrice(price);
  }

  static String _addThousandSeparator(String number) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = number.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(number[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  static String gregorianToJalali(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${toPersianDigits(j.day.toString())} ${_persianMonths[j.month - 1]} ${toPersianDigits(j.year.toString())}';
  }

  static String jalaliMonthYear(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${_persianMonths[j.month - 1]} ${toPersianDigits(j.year.toString())}';
  }

  static String jalaliShort(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${toPersianDigits(j.day.toString())}/${toPersianDigits(j.month.toString())}/${toPersianDigits(j.year.toString())}';
  }

  static String weekDayName(DateTime date) {
    // In Iran, Saturday is the first day of week
    // DateTime.weekday: Monday=1, Tuesday=2, ..., Saturday=6, Sunday=7
    final iranianWeekday = {
      DateTime.saturday: 0,
      DateTime.sunday: 1,
      DateTime.monday: 2,
      DateTime.tuesday: 3,
      DateTime.wednesday: 4,
      DateTime.thursday: 5,
      DateTime.friday: 6,
    };
    return _persianWeekDays[iranianWeekday[date.weekday] ?? 0];
  }

  static String formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    return toPersianDigits('$hour:$minute');
  }

  static bool isValidIranPhone(String phone) {
    return RegExp(r'^09[0-9]{9}$').hasMatch(phone);
  }

  static List<DateTime> getJalaliMonthDays(int jYear, int jMonth) {
    final days = <DateTime>[];
    final daysInMonth = Jalali(jYear, jMonth).monthLength;
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(Jalali(jYear, jMonth, d).toDateTime());
    }
    return days;
  }

  static Jalali getCurrentJalali() => Jalali.now();

  static String getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 30) {
      return gregorianToJalali(dateTime);
    } else if (diff.inDays > 0) {
      return '${toPersianDigits(diff.inDays.toString())} روز پیش';
    } else if (diff.inHours > 0) {
      return '${toPersianDigits(diff.inHours.toString())} ساعت پیش';
    } else {
      return '${toPersianDigits(diff.inMinutes.toString())} دقیقه پیش';
    }
  }
}
