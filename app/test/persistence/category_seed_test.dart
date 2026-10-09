import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/persistence/app_database.dart';
import 'package:mis_gastos/persistence/category_seed.dart';

import 'test_support.dart';

const Map<String, List<String>> documentedSeed = {
  'needs': [
    'Transporte público',
    'Transporte privado',
    'Salud',
    'Alimentación hogar',
    'Arriendo',
    'Servicios',
    'Mantenimiento casa',
    'Mantenimiento bicicleta',
    'Mantenimiento computador',
    'Otros gastos únicos obligatorios',
  ],
  'wants': [
    'Belleza',
    'Ropa',
    'Snacks',
    'Snacks trabajo',
    'Salidas',
    'Comidas por la calle',
  ],
};

void main() {
  late AppDatabase db;
  late CategorySeeder seeder;

  setUp(() {
    db = openInMemoryTestDatabase();
    seeder = CategorySeeder(db, clock: fixedTestClock);
  });
  tearDown(() => db.close());

  Future<List<String>> categorySnapshot() async {
    final query = db.select(db.categories)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        '${row.id}|${row.name}|${row.normalizedName}|${row.defaultBucket}|'
            '${row.isActive}|${row.seedKey}|'
            '${row.createdAt.toUtc().toIso8601String()}|'
            '${row.updatedAt.toUtc().toIso8601String()}',
    ];
  }

  test(
    'seeds only the documented initial categories with their buckets',
    () async {
      final inserted = await seeder.seedInitialCategories();

      expect(inserted, 16);
      final rows = await db.select(db.categories).get();
      expect(rows, hasLength(16));
      for (final entry in documentedSeed.entries) {
        expect(
          rows
              .where((row) => row.defaultBucket == entry.key)
              .map((row) => row.name)
              .toSet(),
          entry.value.toSet(),
          reason: 'Unexpected ${entry.key} categories',
        );
      }
      expect(rows.every((row) => row.isActive), isTrue);
      expect(
        rows.every((row) => row.normalizedName == row.name.toLowerCase()),
        isTrue,
      );
      expect(rows.where((row) => row.seedKey == null), isEmpty);
    },
  );

  test(
    'is idempotent: the second run inserts nothing and leaves state unchanged',
    () async {
      await seeder.seedInitialCategories();
      final before = await categorySnapshot();

      final secondRun = await seeder.seedInitialCategories();
      final after = await categorySnapshot();

      expect(secondRun, 0);
      expect(after, equals(before));
      expect(await db.categories.count().getSingle(), 16);
    },
  );

  test(
    'skips a seed entry already present with an equivalent normalized name',
    () async {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'ropa',
              normalizedName: 'ropa',
              defaultBucket: 'wants',
              createdAt: fixedTestClock(),
              updatedAt: fixedTestClock(),
            ),
          );

      final inserted = await seeder.seedInitialCategories();

      expect(inserted, 15);
      expect(await db.categories.count().getSingle(), 16);
      final seeded = await db.select(db.categories).get();
      expect(seeded.where((row) => row.normalizedName == 'ropa'), hasLength(1));
    },
  );
}
