import 'package:drift/drift.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Source of technical audit timestamps.
///
/// Financial dates are never read from this clock: callers pass the financial
/// day explicitly so periods stay reproducible (ADR-006).
typedef Clock = DateTime Function();

/// Default [Clock]: a UTC instant.
DateTime systemUtcClock() => DateTime.now().toUtc();

/// Local-first SQLite database (ADR-002).
///
/// Schema v1 only contains what the first expense slice exercises: one cash
/// account, seeded categories, and `expense`/`opening_balance` operations
/// (ADR-009 amendment). Everything else is added by a later versioned
/// migration.
@DriftDatabase(tables: [Accounts, Categories, Operations])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    beforeOpen: (OpeningDetails details) async {
      // SQLite leaves foreign keys disabled per connection; keep the real
      // operation -> account/category relations enforced (ADR-007).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
