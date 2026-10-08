import 'dart:math' as math;

import '../models/log_entry.dart';
import 'date_utils.dart';

// Streaks + badges, computed entirely from the user's existing logged data
// (no extra table). A day is "active" if it has at least one meal/exercise
// entry OR any water logged. All day math uses the local-date helpers.

class StreakStats {
  const StreakStats({
    required this.current,
    required this.longest,
    required this.activeDays,
    required this.totalEntries,
    required this.hydrationDays,
    required this.todayActive,
  });

  final int current; // consecutive active days ending today (or yesterday)
  final int longest; // longest run of active days ever
  final int activeDays; // total distinct active days
  final int totalEntries; // total meal/exercise entries logged
  final int hydrationDays; // distinct days with water logged
  final bool todayActive; // has the user logged anything today
}

class Achievement {
  const Achievement({required this.id, required this.emoji, required this.earned});

  /// Also the l10n key suffix (`chartsBadges<Id>Label` / `Desc`).
  final String id;
  final String emoji;
  final bool earned;
}

StreakStats computeStreakStats(List<LogEntry> entries, Map<String, double> hydration, {String? today}) {
  final active = <String>{for (final e in entries) e.date};

  var hydrationDays = 0;
  hydration.forEach((date, ml) {
    if (ml > 0) {
      hydrationDays++;
      active.add(date);
    }
  });

  final todayDate = today ?? todayStr();
  final todayActive = active.contains(todayDate);

  // Current streak: count back from today; if today isn't logged yet but
  // yesterday was, the streak is still alive, so start from yesterday.
  var current = 0;
  var cursor = todayActive ? todayDate : addDays(todayDate, -1);
  while (active.contains(cursor)) {
    current++;
    cursor = addDays(cursor, -1);
  }

  // Longest streak: sort the active days and find the longest consecutive run.
  final sorted = active.toList()..sort();
  var longest = 0;
  var run = 0;
  String? prev;
  for (final d in sorted) {
    run = prev != null && addDays(prev, 1) == d ? run + 1 : 1;
    longest = math.max(longest, run);
    prev = d;
  }

  return StreakStats(
    current: current,
    longest: longest,
    activeDays: active.length,
    totalEntries: entries.length,
    hydrationDays: hydrationDays,
    todayActive: todayActive,
  );
}

typedef _BadgeDef = ({String id, String emoji, bool Function(StreakStats) test});

// `best` = the higher of current/longest so an earned streak badge stays earned
// even after a miss.
int _best(StreakStats s) => math.max(s.current, s.longest);

final List<_BadgeDef> _badgeDefs = [
  (id: 'start', emoji: '🌱', test: (s) => s.totalEntries >= 1),
  (id: 'streak3', emoji: '🔥', test: (s) => _best(s) >= 3),
  (id: 'streak7', emoji: '🚀', test: (s) => _best(s) >= 7),
  (id: 'streak14', emoji: '💪', test: (s) => _best(s) >= 14),
  (id: 'streak30', emoji: '🏆', test: (s) => _best(s) >= 30),
  (id: 'hydrated', emoji: '💧', test: (s) => s.hydrationDays >= 7),
  (id: 'century', emoji: '💯', test: (s) => s.totalEntries >= 100),
];

List<Achievement> computeBadges(StreakStats stats) => [
  for (final b in _badgeDefs) Achievement(id: b.id, emoji: b.emoji, earned: b.test(stats)),
];
