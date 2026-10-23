import 'domain_exception.dart';
import 'money.dart';
import 'operation_date.dart';

/// Operation kinds implemented by the first expense slice.
///
/// ADR-009 amendment: only `expense` and `opening_balance` exist in the first
/// slice. Every other kind is deferred until its flow is authorized.
enum OperationKind {
  expense('expense'),
  openingBalance('opening_balance');

  const OperationKind(this.wireName);

  /// Canonical ADR-009 kind name, also intended for future persistence.
  final String wireName;
}

/// Historical 50/30/20 bucket for the first slice.
///
/// `SAVINGS` is intentionally absent: it is reserved for savings contributions,
/// which are outside the first-slice scope.
enum Bucket { needs, wants }

/// A financial event with an exact positive amount and a calendar date.
sealed class Operation {
  Operation({required this.amount, required this.date}) {
    if (amount.minorUnits == 0) {
      throw const InvalidOperationException(
        'Operation amount must be greater than zero.',
      );
    }
  }

  final Money amount;
  final OperationDate date;

  OperationKind get kind;
}

/// An ordinary expense that carries its historical bucket.
final class ExpenseOperation extends Operation {
  ExpenseOperation({
    required super.amount,
    required super.date,
    required this.bucket,
  });

  /// Historical NEEDS/WANTS classification captured at creation time.
  ///
  /// A category may only propose this value; the value stored here is the
  /// historical truth and is never re-derived from the category.
  final Bucket bucket;

  @override
  OperationKind get kind => OperationKind.expense;
}

/// Initial available cash.
///
/// It is an available-cash movement, not income, and therefore has no bucket
/// identity.
final class OpeningBalanceOperation extends Operation {
  OpeningBalanceOperation({required super.amount, required super.date});

  @override
  OperationKind get kind => OperationKind.openingBalance;
}
