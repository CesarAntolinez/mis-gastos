import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';
import 'package:mis_gastos/domain/operation.dart';
import 'package:mis_gastos/domain/operation_date.dart';
import 'package:mis_gastos/persistence/app_database.dart';
import 'package:mis_gastos/persistence/cash_account_setup.dart';
import 'package:mis_gastos/persistence/category_seed.dart';
import 'package:mis_gastos/persistence/operation_mapper.dart';
import 'package:mis_gastos/persistence/operation_repository.dart';

import 'test_support.dart';

void main() {
  late AppDatabase db;
  late OperationRepository repository;
  late int accountId;
  late int categoryId;
  final effectiveDate = OperationDate(2026, 10, 8);

  setUp(() async {
    db = openInMemoryTestDatabase();
    accountId = (await CashAccountSetup(
      db,
      clock: fixedTestClock,
    ).ensureCashAccount()).id;
    await CategorySeeder(db, clock: fixedTestClock).seedInitialCategories();
    final categories = await db.select(db.categories).get();
    categoryId = categories.singleWhere((row) => row.name == 'Ropa').id;
    repository = OperationRepository(db, clock: fixedTestClock);
  });
  tearDown(() => db.close());

  OperationRow persistedRow({
    String kind = 'expense',
    String? bucket = 'needs',
    int amountMinor = 25000,
    int effectiveDateValue = 20261008,
    String currencyCode = 'COP',
    int? categoryId,
  }) => OperationRow(
    id: 1,
    kind: kind,
    effectiveDate: effectiveDateValue,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    bucket: bucket,
    accountId: accountId,
    categoryId: categoryId,
    createdAt: fixedTestClock(),
    updatedAt: fixedTestClock(),
  );

  group('round trip', () {
    test('keeps kind, date, amount, bucket and links for an expense', () async {
      final expense = ExpenseOperation(
        amount: Money.cop(25000),
        date: effectiveDate,
        bucket: Bucket.wants,
      );

      final persisted = await repository.insert(
        expense,
        accountId: accountId,
        categoryId: categoryId,
      );
      final read = await repository.findById(persisted.id);

      expect(read, isNotNull);
      expect(read!.accountId, accountId);
      expect(read.categoryId, categoryId);
      expect(read.operation.kind, OperationKind.expense);
      expect(read.operation.date, effectiveDate);
      expect(read.operation.amount, Money.cop(25000));
      expect((read.operation as ExpenseOperation).bucket, Bucket.wants);

      final row = await (db.select(
        db.operations,
      )..where((table) => table.id.equals(persisted.id))).getSingle();
      expect(row.kind, 'expense');
      expect(row.bucket, 'wants');
      expect(row.effectiveDate, 20261008);
      expect(row.createdAt.toUtc(), fixedTestClock());
      expect(row.updatedAt.toUtc(), fixedTestClock());
    });

    test('keeps an opening balance free of bucket identity', () async {
      final opening = OpeningBalanceOperation(
        amount: Money.cop(750000),
        date: effectiveDate,
      );

      final persisted = await repository.insert(opening, accountId: accountId);
      final read = await repository.findById(persisted.id);

      expect(read!.operation.kind, OperationKind.openingBalance);
      expect(read.operation, isNot(isA<ExpenseOperation>()));
      expect(read.operation.amount, Money.cop(750000));
      expect(read.categoryId, isNull);
      expect(
        await (db.select(
          db.operations,
        )..where((table) => table.id.equals(persisted.id))).getSingle(),
        isA<OperationRow>().having((row) => row.bucket, 'bucket', isNull),
      );
    });

    test('returns null for an unknown operation id', () async {
      expect(await repository.findById(404), isNull);
    });
  });

  group('boundary validation', () {
    const mapper = OperationMapper();

    test('rejects persisted rows with a non-positive amount', () {
      expect(
        () => mapper.toDomain(persistedRow(amountMinor: 0)),
        throwsA(isA<InvalidOperationException>()),
      );
      expect(
        () => mapper.toDomain(persistedRow(amountMinor: -25000)),
        throwsA(isA<NegativeMoneyException>()),
      );
    });

    test('rejects persisted rows outside the first-slice vocabulary', () {
      expect(
        () => mapper.toDomain(persistedRow(kind: 'income')),
        throwsA(isA<InvalidOperationException>()),
      );
      expect(
        () => mapper.toDomain(persistedRow(kind: 'expense', bucket: null)),
        throwsA(isA<InvalidOperationException>()),
      );
      expect(
        () => mapper.toDomain(persistedRow(kind: 'opening_balance')),
        throwsA(isA<InvalidOperationException>()),
      );
      expect(
        () => mapper.toDomain(persistedRow(bucket: 'savings')),
        throwsA(isA<InvalidOperationException>()),
      );
      expect(
        () => mapper.toDomain(persistedRow(effectiveDateValue: 20260230)),
        throwsA(isA<InvalidOperationDateException>()),
      );
    });

    test('rejects an opening balance linked to a category', () async {
      final opening = OpeningBalanceOperation(
        amount: Money.cop(1000),
        date: effectiveDate,
      );

      await expectLater(
        repository.insert(
          opening,
          accountId: accountId,
          categoryId: categoryId,
        ),
        throwsA(isA<InvalidOperationException>()),
      );
    });

    test('rejects an opening balance row that carries a category', () {
      expect(
        () => mapper.toDomain(
          persistedRow(
            kind: 'opening_balance',
            bucket: null,
            categoryId: categoryId,
          ),
        ),
        throwsA(isA<InvalidOperationException>()),
      );
    });

    test(
      'rejects an operation whose currency does not match the account',
      () async {
        final foreign = OpeningBalanceOperation(
          amount: Money.fromMinorUnits(1000, const Currency('USD')),
          date: effectiveDate,
        );

        await expectLater(
          repository.insert(foreign, accountId: accountId),
          throwsA(isA<CurrencyMismatchException>()),
        );
      },
    );

    test('rejects an operation for an unknown account', () async {
      final expense = ExpenseOperation(
        amount: Money.cop(1000),
        date: effectiveDate,
        bucket: Bucket.needs,
      );

      await expectLater(
        repository.insert(expense, accountId: 9999, categoryId: categoryId),
        throwsA(isA<InvalidOperationException>()),
      );
    });
  });
}
