import 'package:drift/drift.dart';

/// Accounts: where money is located (ADR-007).
///
/// The first slice only ever creates one `cash` account. No opening balance is
/// stored on the account row: available cash is a traceable `opening_balance`
/// operation, never a duplicated account field (ADR-009).
@DataClassName('AccountRow')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// ADR-007 account type vocabulary. The first slice only creates `cash`.
  TextColumn get type => text()();

  /// ISO 4217 code. The MVP only persists `COP` (ADR-005, ADR-009).
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Technical audit timestamps: UTC instants, never financial dates (ADR-006).
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK (type IN ('cash', 'bank', 'savings', 'other'))",
  ];
}

/// Categories: master data that only *proposes* a historical bucket
/// (docs/product/configuration.md, ADR-009 amendment).
@DataClassName('CategoryRow')
// Stable identity of a seeded category, so re-seeding can never duplicate it
// even if its display name is edited later.
@TableIndex.sql(
  'CREATE UNIQUE INDEX categories_seed_key ON categories (seed_key) '
  'WHERE seed_key IS NOT NULL;',
)
// Documented rule: no two ACTIVE categories share a normalized name. Inactive
// duplicates stay possible, so the index is partial.
@TableIndex.sql(
  'CREATE UNIQUE INDEX categories_active_normalized_name ON categories '
  '(normalized_name) WHERE is_active = 1;',
)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Display name; original capitalization is preserved.
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Duplicate detection form: `trim` + case-insensitive.
  TextColumn get normalizedName => text().withLength(min: 1, max: 80)();

  /// `needs` or `wants`. Ordinary categories never propose savings.
  TextColumn get defaultBucket => text()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Non-null for the documented initial seed; the value is name independent.
  TextColumn get seedKey => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK (default_bucket IN ('needs', 'wants'))",
    "CHECK (length(trim(name)) > 0)",
  ];
}

/// Financial operations: what happened, independent of how it is displayed
/// (ADR-007, ADR-009).
@DataClassName('OperationRow')
@TableIndex(name: 'operations_effective_date', columns: {#effectiveDate})
@TableIndex(name: 'operations_account_id', columns: {#accountId})
class Operations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Canonical ADR-009 kind wire value (`expense`, `opening_balance`).
  TextColumn get kind => text()();

  /// Financial date encoded as `yyyymmdd`: a plain civil day with no
  /// time-of-day and no time zone, never a timestamp (ADR-006). Financial
  /// periods are derived from it in Dart, not from SQLite date functions.
  IntColumn get effectiveDate => integer()();

  /// Exact amount in integer minor units (ADR-005). Never `REAL`.
  IntColumn get amountMinor => integer()();

  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  /// Historical NEEDS/WANTS bucket, present for `expense` and absent for
  /// `opening_balance` (ADR-009 amendment). The value is a snapshot: changing
  /// a category never rewrites it.
  TextColumn get bucket => text().nullable()();

  IntColumn get accountId => integer().references(Accounts, #id)();

  /// Optional category link (ADR-007). `opening_balance` never uses one.
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
    "CHECK (kind IN ('expense', 'opening_balance'))",
    "CHECK (bucket IS NULL OR bucket IN ('needs', 'wants'))",
  ];
}
