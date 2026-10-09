import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';
import 'package:mis_gastos/domain/operation.dart';
import 'package:mis_gastos/domain/operation_date.dart';
import 'package:mis_gastos/persistence/app_database.dart';
import 'package:mis_gastos/persistence/cash_account_setup.dart';

import 'test_support.dart';

void main() {
  late AppDatabase db;
  late CashAccountSetup setup;
  final effectiveDate = OperationDate(2026, 10, 8);

  setUp(() {
    db = openInMemoryTestDatabase();
    setup = CashAccountSetup(db, clock: fixedTestClock);
  });
  tearDown(() => db.close());

  Future<int> accountCount() async =>
      (await db.select(db.accounts).get()).length;

  Future<int> operationCount() async =>
      (await db.select(db.operations).get()).length;

  test(
    'creates the single cash account once and reuses it afterwards',
    () async {
      final first = await setup.ensureCashAccount();
      final second = await setup.ensureCashAccount();

      expect(second.id, first.id);
      expect(await accountCount(), 1);
      expect(first.type, 'cash');
      expect(first.currencyCode, 'COP');
      expect(first.name, CashAccountSetup.defaultCashAccountName);
      expect(first.isArchived, isFalse);
    },
  );

  test(
    'uses the caller-provided name when the cash account is created',
    () async {
      final account = await setup.ensureCashAccount(name: 'Efectivo casa');

      expect(account.name, 'Efectivo casa');
    },
  );

  test(
    'records exactly one opening_balance operation for a positive amount',
    () async {
      final result = await setup.setup(
        initialAvailableCash: Money.cop(2000000),
        effectiveDate: effectiveDate,
      );

      final rows = await db.select(db.operations).get();
      expect(rows, hasLength(1));
      expect(result.openingBalanceOperation, isNotNull);
      expect(result.openingBalanceOperation!.id, rows.single.id);

      final row = rows.single;
      expect(row.kind, OperationKind.openingBalance.wireName);
      expect(row.amountMinor, 2000000);
      expect(row.currencyCode, 'COP');
      expect(row.effectiveDate, 20261008);
      expect(row.accountId, result.account.id);
      expect(row.categoryId, isNull);
      expect(row.bucket, isNull);
    },
  );

  test('creates no operation for a zero initial available cash', () async {
    final result = await setup.setup(
      initialAvailableCash: Money.cop(0),
      effectiveDate: effectiveDate,
    );

    expect(result.openingBalanceOperation, isNull);
    expect(await operationCount(), 0);
    expect(await accountCount(), 1);
  });

  test(
    'creates no operation when the initial available cash is omitted',
    () async {
      final result = await setup.setup(effectiveDate: effectiveDate);

      expect(result.openingBalanceOperation, isNull);
      expect(await operationCount(), 0);
      expect(await accountCount(), 1);
    },
  );

  test('never records a second opening balance for the account', () async {
    await setup.setup(
      initialAvailableCash: Money.cop(150000),
      effectiveDate: effectiveDate,
    );

    await setup.setup(effectiveDate: effectiveDate);
    await expectLater(
      setup.setup(
        initialAvailableCash: Money.cop(90000),
        effectiveDate: effectiveDate,
      ),
      throwsA(isA<InvalidOperationException>()),
    );
    expect(await accountCount(), 1);
    expect(await operationCount(), 1);
  });
}
