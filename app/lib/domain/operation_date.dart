import 'domain_exception.dart';

/// A plain calendar date (year/month/day) with no time-of-day.
///
/// Financial periods are derived from this civil date, never from a technical
/// timestamp or from the machine time zone (ADR-006).
final class OperationDate implements Comparable<OperationDate> {
  const OperationDate._(this.year, this.month, this.day);

  factory OperationDate(int year, int month, int day) {
    final isValid =
        year >= 1 &&
        month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= daysInMonth(year, month);
    if (!isValid) {
      throw InvalidOperationDateException(year, month, day);
    }
    return OperationDate._(year, month, day);
  }

  final int year;
  final int month;
  final int day;

  static const List<int> _daysPerMonth = <int>[
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  /// Days in [month] for [year], or `0` when [month] is not 1..12.
  static int daysInMonth(int year, int month) {
    if (month < 1 || month > 12) {
      return 0;
    }
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }
    return _daysPerMonth[month - 1];
  }

  @override
  int compareTo(OperationDate other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is OperationDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
