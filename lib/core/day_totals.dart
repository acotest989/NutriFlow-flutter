import '../models/log_entry.dart';

/// Calorie + macro totals for one calendar day.
class DayTotals {
  const DayTotals({
    required this.consumed,
    required this.burned,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double consumed; // meal kcal
  final double burned; // exercise kcal (stored positive)
  final double protein;
  final double carbs;
  final double fat;

  double get net => consumed - burned;

  factory DayTotals.of(Iterable<LogEntry> entries, String date) {
    var consumed = 0.0, burned = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0;
    for (final e in entries) {
      if (e.date != date) continue;
      if (e.isMeal) {
        consumed += e.calories;
        protein += e.protein;
        carbs += e.carbs;
        fat += e.fat;
      } else {
        burned += e.calories;
      }
    }
    return DayTotals(consumed: consumed, burned: burned, protein: protein, carbs: carbs, fat: fat);
  }
}

/// Most recent distinct items of [type] (by name, newest first) for one-tap
/// re-logging. `entries` is already newest-first.
List<LogEntry> recentDistinct(List<LogEntry> entries, EntryType type, {int limit = 15}) {
  final seen = <String>{};
  final out = <LogEntry>[];
  for (final e in entries) {
    if (e.type != type) continue;
    if (!seen.add(e.name.toLowerCase())) continue;
    out.add(e);
    if (out.length >= limit) break;
  }
  return out;
}
