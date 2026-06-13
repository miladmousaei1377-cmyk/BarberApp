import 'package:flutter_test/flutter_test.dart';
import 'package:barberbook/data/mock/mock_data.dart';
import 'package:barberbook/core/utils/persian_utils.dart';

void main() {
  group('MockData', () {
    setUp(() => MockData.init());

    test('salons loaded', () {
      expect(MockData.salons.length, equals(5));
    });

    test('services loaded', () {
      expect(MockData.services.isNotEmpty, isTrue);
    });

    test('stylists loaded', () {
      expect(MockData.stylists.isNotEmpty, isTrue);
    });

    test('no double booking', () {
      final slots = MockData.getAvailableSlots(
        's1', null, DateTime.now().add(const Duration(days: 1)), 30,
      );
      expect(slots.isNotEmpty, isTrue);
    });
  });

  group('PersianUtils', () {
    test('converts digits', () {
      expect(PersianUtils.toPersianDigits('123'), equals('۱۲۳'));
    });

    test('formats price', () {
      expect(PersianUtils.formatPrice(120000), contains('تومان'));
    });

    test('validates iran phone', () {
      expect(PersianUtils.isValidIranPhone('09123456789'), isTrue);
      expect(PersianUtils.isValidIranPhone('12345'), isFalse);
    });

    test('jalali conversion', () {
      final result = PersianUtils.gregorianToJalali(DateTime(2024, 1, 1));
      expect(result.isNotEmpty, isTrue);
    });
  });
}
