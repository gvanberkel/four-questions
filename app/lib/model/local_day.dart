import 'package:flutter/foundation.dart';

/// A calendar day on the device's clock — the unit answers are kept by.
@immutable
class LocalDay implements Comparable<LocalDay> {
  const LocalDay(this.year, this.month, this.day);

  factory LocalDay.of(DateTime time) =>
      LocalDay(time.year, time.month, time.day);

  /// Google Sheets counts days from 30 December 1899.
  factory LocalDay.fromSheetsSerial(num serial) =>
      LocalDay.of(DateTime.utc(1899, 12, 30).add(Duration(days: serial.floor())));

  final int year;
  final int month;
  final int day;

  static final _iso = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})');

  /// Reads `2026-10-08` or `2026/10/08`; anything else is not a day.
  static LocalDay? tryParse(String text) {
    final match = _iso.firstMatch(text.trim());
    if (match == null) return null;
    final day = LocalDay(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    final check = DateTime(day.year, day.month, day.day);
    return check.month == day.month && check.day == day.day ? day : null;
  }

  String get iso => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  DateTime get date => DateTime(year, month, day);

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
    'Sunday',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', //
    'August', 'September', 'October', 'November', 'December',
  ];

  /// "Thursday 8 October".
  String get spoken => '${_weekdays[date.weekday - 1]} $day ${_months[month - 1]}';

  @override
  int compareTo(LocalDay other) => iso.compareTo(other.iso);

  @override
  bool operator ==(Object other) =>
      other is LocalDay &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}
