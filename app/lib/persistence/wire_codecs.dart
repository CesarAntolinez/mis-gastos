import 'package:mis_gastos/domain/domain_exception.dart';
import 'package:mis_gastos/domain/operation.dart';
import 'package:mis_gastos/domain/operation_date.dart';

/// Wire values shared by the persisted schema and the domain kernel.
///
/// Values come from the canonical vocabulary: `OperationKind.wireName`
/// (ADR-009) and the documented `NEEDS`/`WANTS` buckets. Unknown values are
/// rejected with domain exceptions instead of being silently coerced.

String kindToWire(OperationKind kind) => kind.wireName;

OperationKind kindFromWire(String wire) {
  for (final kind in OperationKind.values) {
    if (kind.wireName == wire) {
      return kind;
    }
  }
  throw InvalidOperationException('Unsupported operation kind: $wire');
}

String bucketToWire(Bucket bucket) => switch (bucket) {
  Bucket.needs => 'needs',
  Bucket.wants => 'wants',
};

Bucket bucketFromWire(String? wire) => switch (wire) {
  'needs' => Bucket.needs,
  'wants' => Bucket.wants,
  _ => throw InvalidOperationException('Unsupported historical bucket: $wire'),
};

/// Encodes a plain financial day as `yyyymmdd` (ADR-006).
///
/// The value carries no time-of-day and no time zone, so it can never drift
/// with the machine locale.
int encodeFinancialDate(OperationDate date) =>
    date.year * 10000 + date.month * 100 + date.day;

/// Decodes a stored `yyyymmdd` day, rejecting anything that is not a real
/// calendar date.
OperationDate decodeFinancialDate(int value) =>
    OperationDate(value ~/ 10000, (value ~/ 100) % 100, value % 100);
