import 'package:drift/native.dart';
import 'package:mis_gastos/persistence/app_database.dart';

/// Opens a fresh in-memory app database.
///
/// Persistence tests never touch the filesystem and never need an emulator
/// (ADR-002, first-expense-slice process constraint).
AppDatabase openInMemoryTestDatabase() => AppDatabase(NativeDatabase.memory());

/// Fixed UTC clock for deterministic technical audit timestamps (ADR-006).
DateTime fixedTestClock() => DateTime.utc(2026, 10, 8, 15, 30);
