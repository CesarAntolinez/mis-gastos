import 'package:flutter_test/flutter_test.dart';
import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/money.dart';

void main() {
  group('Money', () {
    test('stores integer minor units with an explicit COP currency', () {
      final money = Money.cop(125000);

      expect(money.minorUnits, 125000);
      expect(money.currency, Currency.cop);
      expect(money.currency.code, 'COP');
    });

    test('accepts zero as a valid amount', () {
      expect(Money.cop(0).minorUnits, 0);
      expect(Money.zero(Currency.cop).minorUnits, 0);
    });

    test('rejects negative amounts with a domain exception', () {
      expect(() => Money.cop(-1), throwsA(isA<NegativeMoneyException>()));
    });

    test('rejects amounts above the supported maximum', () {
      expect(
        () => Money.cop(Money.maxMinorUnits + 1),
        throwsA(isA<MoneyOverflowException>()),
      );
    });

    test('adds amounts of the same currency', () {
      expect((Money.cop(25000) + Money.cop(75000)).minorUnits, 100000);
    });

    test('rejects addition that exceeds the supported maximum', () {
      expect(
        () => Money.cop(Money.maxMinorUnits) + Money.cop(1),
        throwsA(isA<MoneyOverflowException>()),
      );
    });

    test('rejects addition across different currencies', () {
      final usd = Money.fromMinorUnits(100, const Currency('USD'));

      expect(
        () => Money.cop(100) + usd,
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('compares amounts of the same currency', () {
      expect(Money.cop(100).compareTo(Money.cop(200)), lessThan(0));
      expect(Money.cop(200).compareTo(Money.cop(100)), greaterThan(0));
      expect(Money.cop(100).compareTo(Money.cop(100)), 0);
      expect(Money.cop(100) < Money.cop(200), isTrue);
      expect(Money.cop(200) >= Money.cop(200), isTrue);
    });

    test('supports value equality', () {
      expect(Money.cop(100), Money.cop(100));
      expect(Money.cop(100).hashCode, Money.cop(100).hashCode);
      expect(Money.cop(100), isNot(Money.cop(101)));
    });
  });

  group('Currency', () {
    test('equality is based on the ISO code', () {
      expect(const Currency('COP'), Currency.cop);
      expect(const Currency('COP'), isNot(const Currency('USD')));
    });
  });
}
