import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/operation_date.dart';

void main() {
  group('OperationDate', () {
    test('constructs a plain calendar date without time-of-day', () {
      final date = OperationDate(2026, 10, 8);

      expect(date.year, 2026);
      expect(date.month, 10);
      expect(date.day, 8);
    });

    test('rejects a month outside 1..12', () {
      expect(
        () => OperationDate(2026, 0, 1),
        throwsA(isA<InvalidOperationDateException>()),
      );
      expect(
        () => OperationDate(2026, 13, 1),
        throwsA(isA<InvalidOperationDateException>()),
      );
    });

    test('rejects day zero and days beyond the month length', () {
      expect(
        () => OperationDate(2026, 1, 0),
        throwsA(isA<InvalidOperationDateException>()),
      );
      expect(
        () => OperationDate(2026, 4, 31),
        throwsA(isA<InvalidOperationDateException>()),
      );
    });

    test('rejects a non-positive year', () {
      expect(
        () => OperationDate(0, 1, 1),
        throwsA(isA<InvalidOperationDateException>()),
      );
    });

    test('handles February in leap and non-leap years', () {
      expect(OperationDate(2024, 2, 29).day, 29);
      expect(
        () => OperationDate(2023, 2, 29),
        throwsA(isA<InvalidOperationDateException>()),
      );
      expect(OperationDate(2000, 2, 29).day, 29);
      expect(
        () => OperationDate(1900, 2, 29),
        throwsA(isA<InvalidOperationDateException>()),
      );
    });

    test('supports value equality', () {
      expect(OperationDate(2026, 10, 8), OperationDate(2026, 10, 8));
      expect(OperationDate(2026, 10, 8), isNot(OperationDate(2026, 10, 9)));
    });
  });
}
