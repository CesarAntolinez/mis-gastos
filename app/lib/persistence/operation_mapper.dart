import 'package:drift/drift.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';
import 'package:mis_gastos/domain/operation.dart';
import 'package:mis_gastos/domain/operation_date.dart';

import 'app_database.dart';
import 'wire_codecs.dart';

/// Translates between the domain kernel and persisted operation rows.
///
/// Persisted rows never cross this boundary: callers exchange domain
/// [Operation] values plus an explicit account/category link (ADR-002,
/// ADR-007). Domain invariants are enforced by the kernel; this mapper only
/// refuses to invent or silently coerce values the schema cannot represent.
final class OperationMapper {
  const OperationMapper();

  OperationsCompanion toCompanion(
    Operation operation, {
    required int accountId,
    int? categoryId,
    required DateTime now,
  }) {
    if (operation is OpeningBalanceOperation && categoryId != null) {
      throw const InvalidOperationException(
        'An opening_balance operation cannot be linked to a category.',
      );
    }

    final timestamp = now.toUtc();
    return OperationsCompanion.insert(
      kind: kindToWire(operation.kind),
      effectiveDate: encodeFinancialDate(operation.date),
      amountMinor: operation.amount.minorUnits,
      currencyCode: operation.amount.currency.code,
      accountId: accountId,
      bucket: Value(switch (operation) {
        ExpenseOperation(:final bucket) => bucketToWire(bucket),
        OpeningBalanceOperation() => null,
      }),
      categoryId: Value(categoryId),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Operation toDomain(OperationRow row) {
    final kind = kindFromWire(row.kind);
    final amount = Money.fromMinorUnits(
      row.amountMinor,
      Currency(row.currencyCode),
    );
    final date = decodeFinancialDate(row.effectiveDate);

    return switch (kind) {
      OperationKind.expense => ExpenseOperation(
        amount: amount,
        date: date,
        bucket: bucketFromWire(row.bucket),
      ),
      OperationKind.openingBalance => _openingBalance(
        amount: amount,
        date: date,
        bucket: row.bucket,
        categoryId: row.categoryId,
      ),
    };
  }

  OpeningBalanceOperation _openingBalance({
    required Money amount,
    required OperationDate date,
    required String? bucket,
    required int? categoryId,
  }) {
    if (bucket != null) {
      throw InvalidOperationException(
        'An opening_balance row cannot carry a historical bucket: $bucket',
      );
    }
    if (categoryId != null) {
      throw InvalidOperationException(
        'An opening_balance row cannot carry a category link: $categoryId',
      );
    }
    return OpeningBalanceOperation(amount: amount, date: date);
  }
}
