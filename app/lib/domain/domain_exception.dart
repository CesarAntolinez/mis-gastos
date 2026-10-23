/// Base type for domain rule violations.
///
/// Domain code rejects invalid states with these exceptions instead of using
/// `assert`, so guards hold in release builds too.
abstract class DomainException implements Exception {
  const DomainException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a monetary amount is constructed as a negative magnitude.
final class NegativeMoneyException extends DomainException {
  const NegativeMoneyException(this.minorUnits)
    : super('Money amount must not be negative: $minorUnits');

  final int minorUnits;
}

/// Thrown when an amount or an addition exceeds [Money.maxMinorUnits].
final class MoneyOverflowException extends DomainException {
  const MoneyOverflowException(this.minorUnits)
    : super('Money amount exceeds the supported maximum: $minorUnits');

  final int minorUnits;
}

/// Thrown when amounts of different currencies are combined.
final class CurrencyMismatchException extends DomainException {
  CurrencyMismatchException(this.left, this.right)
    : super('Cannot combine different currencies: $left vs $right');

  final Object left;
  final Object right;
}

/// Thrown when a calendar date is not a real date.
final class InvalidOperationDateException extends DomainException {
  const InvalidOperationDateException(this.year, this.month, this.day)
    : super('Not a real calendar date: $year-$month-$day');

  final int year;
  final int month;
  final int day;
}

/// Thrown when an operation violates the kernel invariants.
final class InvalidOperationException extends DomainException {
  const InvalidOperationException(super.message);
}
