import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow/core/date_utils.dart';
import 'package:nutriflow/core/streaks.dart';
import 'package:nutriflow/models/log_entry.dart';

final today = todayStr();
String daysAgo(int n) => addDays(today, -n);

var _id = 0;
LogEntry entry(String date, [EntryType type = EntryType.meal]) => LogEntry(
  id: 'e${_id++}',
  date: date,
  type: type,
  name: 'x',
  calories: 100,
  protein: 0,
  carbs: 0,
  fat: 0,
  quantity: 1,
  timestamp: '2026-01-01T00:00:00.000Z',
);

bool earned(List<Achievement> badges, String id) => badges.firstWhere((b) => b.id == id).earned;

void main() {
  group('computeStreakStats', () {
    test('is all-zero for no data', () {
      final s = computeStreakStats([], {});
      expect([s.current, s.longest, s.activeDays, s.totalEntries, s.hydrationDays], [0, 0, 0, 0, 0]);
      expect(s.todayActive, isFalse);
    });

    test('counts a streak that includes today', () {
      final s = computeStreakStats([entry(today)], {});
      expect(s.todayActive, isTrue);
      expect(s.current, 1);
      expect(s.longest, 1);
      expect(s.activeDays, 1);
      expect(s.totalEntries, 1);
    });

    test("keeps the streak alive from yesterday when today isn't logged yet", () {
      final s = computeStreakStats([entry(daysAgo(1))], {});
      expect(s.todayActive, isFalse);
      expect(s.current, 1);
    });

    test('resets current to 0 once a whole day is missed', () {
      final s = computeStreakStats([entry(daysAgo(2))], {});
      expect(s.current, 0);
      expect(s.longest, 1);
    });

    test('counts consecutive days ending today', () {
      final s = computeStreakStats([entry(today), entry(daysAgo(1)), entry(daysAgo(2))], {});
      expect(s.current, 3);
      expect(s.longest, 3);
    });

    test("finds the longest run even when it isn't the current one", () {
      final s = computeStreakStats([
        entry(today),
        entry(daysAgo(1)),
        entry(daysAgo(5)),
        entry(daysAgo(6)),
        entry(daysAgo(7)),
        entry(daysAgo(8)),
      ], {});
      expect(s.current, 2);
      expect(s.longest, 4);
      expect(s.activeDays, 6);
    });

    test('treats a day with water logged as active', () {
      final s = computeStreakStats([], {today: 500});
      expect(s.todayActive, isTrue);
      expect(s.current, 1);
      expect(s.hydrationDays, 1);
      expect(s.totalEntries, 0);
    });

    test('ignores 0 ml hydration days', () {
      final s = computeStreakStats([], {today: 0});
      expect(s.todayActive, isFalse);
      expect(s.activeDays, 0);
      expect(s.hydrationDays, 0);
    });

    test('unions entry-days and hydration-days', () {
      final s = computeStreakStats([entry(today)], {daysAgo(1): 250});
      expect(s.activeDays, 2);
      expect(s.current, 2);
      expect(s.hydrationDays, 1);
      expect(s.totalEntries, 1);
    });

    test('counts multiple entries on one day as one active day but all entries', () {
      final s = computeStreakStats([entry(today), entry(today, EntryType.exercise)], {});
      expect(s.activeDays, 1);
      expect(s.totalEntries, 2);
      expect(s.current, 1);
    });
  });

  group('computeBadges', () {
    test("unlocks 'start' on the first entry, not before", () {
      expect(earned(computeBadges(computeStreakStats([], {})), 'start'), isFalse);
      expect(earned(computeBadges(computeStreakStats([entry(today)], {})), 'start'), isTrue);
    });

    test('unlocks streak badges by the best (current or longest) run', () {
      final week = [for (var i = 0; i < 7; i++) entry(daysAgo(i))];
      final badges = computeBadges(computeStreakStats(week, {}));
      expect(earned(badges, 'streak3'), isTrue);
      expect(earned(badges, 'streak7'), isTrue);
      expect(earned(badges, 'streak14'), isFalse);
    });

    test("unlocks 'hydrated' after water on 7 distinct days", () {
      final seven = {for (var i = 0; i < 7; i++) daysAgo(i): 300.0};
      final six = {for (var i = 0; i < 6; i++) daysAgo(i): 300.0};
      expect(earned(computeBadges(computeStreakStats([], seven)), 'hydrated'), isTrue);
      expect(earned(computeBadges(computeStreakStats([], six)), 'hydrated'), isFalse);
    });

    test("unlocks 'century' at 100 total entries", () {
      expect(
        earned(computeBadges(computeStreakStats([for (var i = 0; i < 100; i++) entry(today)], {})), 'century'),
        isTrue,
      );
      expect(
        earned(computeBadges(computeStreakStats([for (var i = 0; i < 99; i++) entry(today)], {})), 'century'),
        isFalse,
      );
    });
  });
}
