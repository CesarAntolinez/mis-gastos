import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';
import 'package:mis_gastos/domain/operation.dart';
import 'package:mis_gastos/domain/operation_date.dart';

void main() {
  final date = OperationDate(2026, 10, 8);

  group('OperationKind', () {
    test('is limited to expense and opening_balance in the first slice', () {
      expect(OperationKind.values, hasLength(2));
      expect(OperationKind.values.map((kind) => kind.wireName).toSet(), {
        'expense',
        'opening_balance',
      });
    });
  });

  group('ExpenseOperation', () {
    test('carries an explicit historical bucket supplied by the caller', () {
      final expense = ExpenseOperation(
        amount: Money.cop(25000),
        date: date,
        bucket: Bucket.needs,
      );

      expect(expense.kind, OperationKind.expense);
      expect(expense.bucket, Bucket.needs);
      expect(expense.amount, Money.cop(25000));
      expect(expense.date, date);
    });

    test('keeps the bucket as stored state instead of deriving it', () {
      final wants = ExpenseOperation(
        amount: Money.cop(1000),
        date: date,
        bucket: Bucket.wants,
      );

      expect(wants.bucket, Bucket.wants);
    });

    test('rejects a zero amount', () {
      expect(
        () => ExpenseOperation(
          amount: Money.cop(0),
          date: date,
          bucket: Bucket.needs,
        ),
        throwsA(isA<InvalidOperationException>()),
      );
    });
  });

  group('OpeningBalanceOperation', () {
    test('has no bucket identity', () {
      final opening = OpeningBalanceOperation(
        amount: Money.cop(500000),
        date: date,
      );

      expect(opening.kind, OperationKind.openingBalance);
      expect(opening, isNot(isA<ExpenseOperation>()));
    });

    test('rejects a zero amount', () {
      expect(
        () => OpeningBalanceOperation(amount: Money.cop(0), date: date),
        throwsA(isA<InvalidOperationException>()),
      );
    });
  });
}
