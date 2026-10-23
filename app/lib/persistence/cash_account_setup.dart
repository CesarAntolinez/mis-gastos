import 'package:drift/drift.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';
import 'package:mis_gastos/domain/operation.dart';
import 'package:mis_gastos/domain/operation_date.dart';

import 'app_database.dart';
import 'operation_repository.dart';

/// Outcome of the minimal cash-account setup.
typedef CashAccountSetupResult = ({
  AccountRow account,
  PersistedOperation? openingBalanceOperation,
});

/// Minimal setup for the single cash account of the first slice.
///
/// Available cash is never stored on the account row; it is a traceable
/// `opening_balance` operation (ADR-009). The correction window that locks the
/// opening balance once financial history exists belongs to the setup flow
/// (task 5), not to this persistence primitive.
final class CashAccountSetup {
  CashAccountSetup(this._db, {Clock? clock})
    : _clock = clock ?? systemUtcClock,
      _operations = OperationRepository(_db, clock: clock);

  /// ADR-007 account type created by the first slice.
  static const String cashAccountType = 'cash';

  /// Name used when the caller does not provide one.
  static const String defaultCashAccountName = 'Efectivo';

  final AppDatabase _db;
  final Clock _clock;
  final OperationRepository _operations;

  /// Returns the cash account, creating it only when it does not exist yet.
  ///
  /// Calling this repeatedly never creates a second account. When an account
  /// already exists, [name] is ignored.
  Future<AccountRow> ensureCashAccount({
    String name = defaultCashAccountName,
  }) async {
    final existingQuery = _db.select(_db.accounts)
      ..where((table) => table.type.equals(cashAccountType))
      ..orderBy([(table) => OrderingTerm.asc(table.id)])
      ..limit(1);
    final existing = await existingQuery.getSingleOrNull();
    if (existing != null) {
      return existing;
    }

    final now = _clock().toUtc();
    final id = await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: name,
            type: cashAccountType,
            currencyCode: Currency.cop.code,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final createdQuery = _db.select(_db.accounts)
      ..where((table) => table.id.equals(id));
    return createdQuery.getSingle();
  }

  /// Ensures the cash account and records the initial available cash.
  ///
  /// A positive [initialAvailableCash] becomes exactly one `opening_balance`
  /// operation dated [effectiveDate]. A `$0` amount (or an omitted one) creates
  /// no operation at all and can never be read as income (ADR-009 amendment,
  /// docs/product/onboarding.md).
  Future<CashAccountSetupResult> setup({
    Money? initialAvailableCash,
    required OperationDate effectiveDate,
    String name = defaultCashAccountName,
  }) {
    return _db.transaction(() async {
      final account = await ensureCashAccount(name: name);
      final amount = initialAvailableCash;
      PersistedOperation? openingBalanceOperation;
      if (amount != null && amount.minorUnits > 0) {
        if (await _hasOpeningBalance(account.id)) {
          throw const InvalidOperationException(
            'Opening balance already recorded for this cash account.',
          );
        }
        openingBalanceOperation = await _operations.insert(
          OpeningBalanceOperation(amount: amount, date: effectiveDate),
          accountId: account.id,
        );
      }
      return (
        account: account,
        openingBalanceOperation: openingBalanceOperation,
      );
    });
  }

  Future<bool> _hasOpeningBalance(int accountId) async {
    final query = _db.select(_db.operations)
      ..where(
        (t) =>
            t.accountId.equals(accountId) &
            t.kind.equals(OperationKind.openingBalance.wireName),
      );
    return await query.getSingleOrNull() != null;
  }
}
