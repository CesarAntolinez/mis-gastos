import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';
import 'package:mis_gastos/domain/operation.dart';

import 'app_database.dart';
import 'operation_mapper.dart';

/// A persisted operation together with its persisted links.
typedef PersistedOperation = ({
  int id,
  int accountId,
  int? categoryId,
  Operation operation,
});

/// Writes and reads financial operations.
///
/// Financial rules stay in the domain kernel. This boundary only enforces the
/// relations the SQL schema cannot express on its own: the account must exist
/// and its currency must match the operation (ADR-007 invariants 1 and 3).
final class OperationRepository {
  OperationRepository(this._db, {Clock? clock})
    : _clock = clock ?? systemUtcClock;

  static const OperationMapper _mapper = OperationMapper();

  final AppDatabase _db;
  final Clock _clock;

  Future<PersistedOperation> insert(
    Operation operation, {
    required int accountId,
    int? categoryId,
  }) async {
    final accountQuery = _db.select(_db.accounts)
      ..where((table) => table.id.equals(accountId));
    final account = await accountQuery.getSingleOrNull();
    if (account == null) {
      throw InvalidOperationException(
        'Cannot persist an operation for unknown account: $accountId',
      );
    }

    final accountCurrency = Currency(account.currencyCode);
    if (accountCurrency != operation.amount.currency) {
      throw CurrencyMismatchException(
        accountCurrency,
        operation.amount.currency,
      );
    }

    final id = await _db
        .into(_db.operations)
        .insert(
          _mapper.toCompanion(
            operation,
            accountId: accountId,
            categoryId: categoryId,
            now: _clock(),
          ),
        );
    return (
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      operation: operation,
    );
  }

  Future<PersistedOperation?> findById(int id) async {
    final query = _db.select(_db.operations)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return (
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      operation: _mapper.toDomain(row),
    );
  }
}
