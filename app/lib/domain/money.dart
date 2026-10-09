import 'domain_exception.dart';

/// ISO 4217-style currency code.
///
/// The MVP only constructs [Currency.cop], but the code stays explicit so the
/// model does not hard-code an irreversible single-currency assumption
/// (ADR-005). Currency conversion remains out of scope.
final class Currency {
  const Currency(this.code);

  static const Currency cop = Currency('COP');

  final String code;

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

/// Exact monetary amount: integer minor units plus an explicit currency.
///
/// Amounts are non-negative magnitudes. Direction and meaning come from the
/// operation kind, never from the sign, and `double` is never used for money
/// (ADR-005).
final class Money implements Comparable<Money> {
  const Money._(this.minorUnits, this.currency);

  factory Money.fromMinorUnits(int minorUnits, Currency currency) {
    if (minorUnits < 0) {
      throw NegativeMoneyException(minorUnits);
    }
    if (minorUnits > maxMinorUnits) {
      throw MoneyOverflowException(minorUnits);
    }
    return Money._(minorUnits, currency);
  }

  factory Money.cop(int minorUnits) =>
      Money.fromMinorUnits(minorUnits, Currency.cop);

  factory Money.zero(Currency currency) => Money.fromMinorUnits(0, currency);

  /// Largest exact amount accepted by the domain kernel.
  ///
  /// Chosen below 2^53 so arithmetic stays exact on every Dart platform.
  static const int maxMinorUnits = 9000000000000000;

  final int minorUnits;
  final Currency currency;

  Money operator +(Money other) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(currency, other.currency);
    }
    final sum = minorUnits + other.minorUnits;
    if (sum > maxMinorUnits) {
      throw MoneyOverflowException(sum);
    }
    return Money._(sum, currency);
  }

  @override
  int compareTo(Money other) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(currency, other.currency);
    }
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => '${currency.code} $minorUnits';
}
