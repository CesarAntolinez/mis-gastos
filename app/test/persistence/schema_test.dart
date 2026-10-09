import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/persistence/app_database.dart';
import 'package:mis_gastos/persistence/cash_account_setup.dart';
import 'package:sqlite3/sqlite3.dart';

import 'test_support.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = openInMemoryTestDatabase());
  tearDown(() => db.close());

  Future<Set<String>> tableNames() async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%';",
        )
        .get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  Future<Map<String, String>> columnTypes(String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table);').get();
    return {
      for (final row in rows)
        row.read<String>('name'): row.read<String>('type').toUpperCase(),
    };
  }

  Future<void> expectRejected(String sql) async {
    await expectLater(
      db.customStatement(sql),
      throwsA(isA<SqliteException>()),
      reason: 'Expected SQLite to reject: $sql',
    );
  }

  test('creates the three first-slice tables', () async {
    expect(await tableNames(), {'accounts', 'categories', 'operations'});
  });

  test('stores money as exact integer minor units', () async {
    final accountColumns = await columnTypes('accounts');
    final categoryColumns = await columnTypes('categories');
    final operationColumns = await columnTypes('operations');

    expect(operationColumns['amount_minor'], 'INTEGER');
    expect(operationColumns['currency_code'], 'TEXT');
    expect(categoryColumns['default_bucket'], 'TEXT');
    expect(categoryColumns['is_active'], 'INTEGER');
    expect(accountColumns['is_archived'], 'INTEGER');
  });

  test(
    'stores financial dates as plain day integers, not timestamps',
    () async {
      final columns = await columnTypes('operations');

      expect(columns['effective_date'], 'INTEGER');
      expect(columns['created_at'], 'INTEGER');
      expect(columns['updated_at'], 'INTEGER');
      for (final type in columns.values) {
        expect(type, isNot('REAL'));
      }
    },
  );

  test('rejects non-positive amounts at the storage boundary', () async {
    final account = await CashAccountSetup(
      db,
      clock: fixedTestClock,
    ).ensureCashAccount();

    await expectRejected(
      "INSERT INTO operations "
      "(kind, effective_date, amount_minor, currency_code, account_id, "
      "created_at, updated_at) "
      "VALUES ('expense', 20261008, 0, 'COP', ${account.id}, 0, 0);",
    );
    await expectRejected(
      "INSERT INTO operations "
      "(kind, effective_date, amount_minor, currency_code, account_id, "
      "created_at, updated_at) "
      "VALUES ('expense', 20261008, -1, 'COP', ${account.id}, 0, 0);",
    );
  });

  test('rejects operation kinds and buckets outside the frozen vocabulary', () async {
    final account = await CashAccountSetup(
      db,
      clock: fixedTestClock,
    ).ensureCashAccount();

    await expectRejected(
      "INSERT INTO operations "
      "(kind, effective_date, amount_minor, currency_code, account_id, "
      "created_at, updated_at) "
      "VALUES ('income', 20261008, 1000, 'COP', ${account.id}, 0, 0);",
    );
    await expectRejected(
      "INSERT INTO operations "
      "(kind, effective_date, amount_minor, currency_code, bucket, account_id, "
      "created_at, updated_at) "
      "VALUES ('expense', 20261008, 1000, 'COP', 'savings', ${account.id}, 0, 0);",
    );
  });

  test('rejects account types and category buckets outside the documented vocabulary', () async {
    await expectRejected(
      "INSERT INTO accounts "
      "(name, type, currency_code, created_at, updated_at) "
      "VALUES ('Cuenta', 'crypto', 'COP', 0, 0);",
    );
    await expectRejected(
      "INSERT INTO categories "
      "(name, normalized_name, default_bucket, created_at, updated_at) "
      "VALUES ('Ahorro', 'ahorro', 'savings', 0, 0);",
    );

    await db.customStatement(
      "INSERT INTO accounts "
      "(name, type, currency_code, created_at, updated_at) "
      "VALUES ('Efectivo', 'cash', 'COP', 0, 0);",
    );
    expect(await db.accounts.count().getSingle(), 1);
  });

  test('protects the seed identity of categories', () async {
    await db.customStatement(
      "INSERT INTO categories "
      "(name, normalized_name, default_bucket, seed_key, created_at, updated_at) "
      "VALUES ('Ropa', 'ropa', 'wants', 'seed.wants.clothing', 0, 0);",
    );

    await expectRejected(
      "INSERT INTO categories "
      "(name, normalized_name, default_bucket, seed_key, created_at, updated_at) "
      "VALUES ('Ropa copia', 'ropa copia', 'wants', 'seed.wants.clothing', 0, 0);",
    );
  });

  test(
    'uniqueness of category names only applies to active categories',
    () async {
      await db.customStatement(
        "INSERT INTO categories "
        "(name, normalized_name, default_bucket, created_at, updated_at) "
        "VALUES ('Ropa', 'ropa', 'wants', 0, 0);",
      );

      await expectRejected(
        "INSERT INTO categories "
        "(name, normalized_name, default_bucket, created_at, updated_at) "
        "VALUES ('ropa', 'ropa', 'wants', 0, 0);",
      );

      await db.customStatement(
        "INSERT INTO categories "
        "(name, normalized_name, default_bucket, is_active, created_at, updated_at) "
        "VALUES ('ROPA', 'ropa', 'needs', 0, 0, 0);",
      );

      expect(await db.categories.count().getSingle(), 2);
    },
  );
}
