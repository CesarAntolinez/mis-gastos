import 'package:drift/drift.dart';
import 'package:mis_gastos/domain/operation.dart';

import 'app_database.dart';
import 'wire_codecs.dart';

/// A category created idempotently by the initialization flow.
///
/// [seedKey] is the stable identity of a seed entry: it does not change when
/// the display name is edited.
typedef CategorySeedEntry = ({
  String seedKey,
  String name,
  Bucket defaultBucket,
});

/// The documented initial category set (docs/product/configuration.md).
///
/// Ten `NEEDS` and six `WANTS` categories. No ordinary savings category
/// exists: savings are operations and financial products.
const List<CategorySeedEntry> initialCategorySeed = <CategorySeedEntry>[
  (
    seedKey: 'seed.needs.public_transport',
    name: 'Transporte público',
    defaultBucket: Bucket.needs,
  ),
  (
    seedKey: 'seed.needs.private_transport',
    name: 'Transporte privado',
    defaultBucket: Bucket.needs,
  ),
  (seedKey: 'seed.needs.health', name: 'Salud', defaultBucket: Bucket.needs),
  (
    seedKey: 'seed.needs.home_food',
    name: 'Alimentación hogar',
    defaultBucket: Bucket.needs,
  ),
  (seedKey: 'seed.needs.rent', name: 'Arriendo', defaultBucket: Bucket.needs),
  (
    seedKey: 'seed.needs.utilities',
    name: 'Servicios',
    defaultBucket: Bucket.needs,
  ),
  (
    seedKey: 'seed.needs.home_maintenance',
    name: 'Mantenimiento casa',
    defaultBucket: Bucket.needs,
  ),
  (
    seedKey: 'seed.needs.bicycle_maintenance',
    name: 'Mantenimiento bicicleta',
    defaultBucket: Bucket.needs,
  ),
  (
    seedKey: 'seed.needs.computer_maintenance',
    name: 'Mantenimiento computador',
    defaultBucket: Bucket.needs,
  ),
  (
    seedKey: 'seed.needs.mandatory_one_off',
    name: 'Otros gastos únicos obligatorios',
    defaultBucket: Bucket.needs,
  ),
  (seedKey: 'seed.wants.beauty', name: 'Belleza', defaultBucket: Bucket.wants),
  (seedKey: 'seed.wants.clothing', name: 'Ropa', defaultBucket: Bucket.wants),
  (seedKey: 'seed.wants.snacks', name: 'Snacks', defaultBucket: Bucket.wants),
  (
    seedKey: 'seed.wants.work_snacks',
    name: 'Snacks trabajo',
    defaultBucket: Bucket.wants,
  ),
  (seedKey: 'seed.wants.outings', name: 'Salidas', defaultBucket: Bucket.wants),
  (
    seedKey: 'seed.wants.street_food',
    name: 'Comidas por la calle',
    defaultBucket: Bucket.wants,
  ),
];

/// Normalized form used to detect duplicates: `trim` + case-insensitive.
///
/// The original capitalization is preserved for display
/// (docs/product/configuration.md).
String normalizeCategoryName(String name) => name.trim().toLowerCase();

/// Creates the documented initial categories exactly once.
final class CategorySeeder {
  CategorySeeder(this._db, {Clock? clock}) : _clock = clock ?? systemUtcClock;

  final AppDatabase _db;
  final Clock _clock;

  /// Inserts the seed categories that are not persisted yet and returns how
  /// many rows were created.
  ///
  /// Running it again after a successful seed inserts nothing and leaves the
  /// existing rows untouched. Identity is the stable
  /// [CategorySeedEntry.seedKey]; an already persisted active category with an
  /// equivalent normalized name is also left alone, because two active
  /// categories must never share a normalized name.
  Future<int> seedInitialCategories() async {
    final existing = await _db.select(_db.categories).get();
    final takenSeedKeys = <String>{
      for (final row in existing)
        if (row.seedKey != null) row.seedKey!,
    };
    final takenActiveNames = <String>{
      for (final row in existing)
        if (row.isActive) row.normalizedName,
    };

    final now = _clock().toUtc();
    final missing = <CategoriesCompanion>[];
    for (final entry in initialCategorySeed) {
      final normalizedName = normalizeCategoryName(entry.name);
      final alreadyPresent =
          takenSeedKeys.contains(entry.seedKey) ||
          takenActiveNames.contains(normalizedName);
      if (alreadyPresent) {
        continue;
      }
      takenSeedKeys.add(entry.seedKey);
      takenActiveNames.add(normalizedName);
      missing.add(
        CategoriesCompanion.insert(
          name: entry.name,
          normalizedName: normalizedName,
          defaultBucket: bucketToWire(entry.defaultBucket),
          seedKey: Value(entry.seedKey),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (missing.isEmpty) {
      return 0;
    }

    await _db.transaction(() async {
      for (final companion in missing) {
        await _db.into(_db.categories).insert(companion);
      }
    });
    return missing.length;
  }
}
