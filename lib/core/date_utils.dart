// Local-timezone calendar-date helpers.
//
// IMPORTANT: never derive a YYYY-MM-DD calendar date from a UTC timestamp
// (e.g. `toUtc().toIso8601String()`). That shifts the day for anyone not on
// UTC, and the logged entry would no longer line up with the day the charts
// bucket it under. All date strings in the app come from LOCAL parts via these
// helpers.

/// Format [d] as YYYY-MM-DD using its LOCAL year/month/day.
String toDateStr(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// Today's local calendar date as YYYY-MM-DD.
String todayStr() => toDateStr(DateTime.now());

/// Parse YYYY-MM-DD as LOCAL midnight.
DateTime parseDateStr(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// Shift a YYYY-MM-DD string by [days], staying in local calendar days.
/// Uses the DateTime constructor (not Duration math) so DST changes can't skip
/// or repeat a day.
String addDays(String dateStr, int days) {
  final d = parseDateStr(dateStr);
  return toDateStr(DateTime(d.year, d.month, d.day + days));
}
