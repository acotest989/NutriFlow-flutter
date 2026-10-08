import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow/core/date_utils.dart';
import 'package:nutriflow/core/day_totals.dart';
import 'package:nutriflow/core/format.dart';
import 'package:nutriflow/models/log_entry.dart';

LogEntry e(String name, EntryType type, double cal, {String date = '2026-05-01', double p = 0}) => LogEntry(
  id: name,
  date: date,
  type: type,
  name: name,
  calories: cal,
  protein: p,
  carbs: 0,
  fat: 0,
  quantity: 1,
  timestamp: '',
);

void main() {
  group('toDateStr', () {
    test('formats local Y/M/D as zero-padded YYYY-MM-DD', () {
      expect(toDateStr(DateTime(2026, 1, 5)), '2026-01-05');
      expect(toDateStr(DateTime(2026, 12, 31)), '2026-12-31');
      expect(toDateStr(DateTime(2026, 9, 9)), '2026-09-09');
    });
  });

  group('addDays', () {
    test('adds and subtracts within a month', () {
      expect(addDays('2026-01-01', 1), '2026-01-02');
      expect(addDays('2026-01-10', 5), '2026-01-15');
      expect(addDays('2026-01-10', -3), '2026-01-07');
    });

    test('crosses month and year boundaries', () {
      expect(addDays('2026-01-01', -1), '2025-12-31');
      expect(addDays('2026-12-31', 1), '2027-01-01');
      expect(addDays('2026-03-01', -1), '2026-02-28');
    });

    test('handles leap days', () {
      expect(addDays('2024-02-28', 1), '2024-02-29');
      expect(addDays('2024-03-01', -1), '2024-02-29');
    });

    test('is a no-op for 0 and reversible', () {
      expect(addDays('2026-07-14', 0), '2026-07-14');
      expect(addDays(addDays('2026-07-14', 9), -9), '2026-07-14');
    });

    test('steps across DST changes one calendar day at a time', () {
      // Europe DST starts 2026-03-29 and ends 2026-10-25.
      expect(addDays('2026-03-28', 1), '2026-03-29');
      expect(addDays('2026-03-29', 1), '2026-03-30');
      expect(addDays('2026-10-26', -1), '2026-10-25');
    });
  });

  test('todayStr round-trips through addDays', () {
    final today = todayStr();
    expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(today), isTrue);
    expect(addDays(addDays(today, 3), -3), today);
  });

  group('DayTotals / recentDistinct', () {
    test('sums meals and exercise separately for one date', () {
      final t = DayTotals.of([
        e('a', EntryType.meal, 500, p: 20),
        e('b', EntryType.meal, 300, p: 10),
        e('c', EntryType.exercise, 200),
        e('d', EntryType.meal, 999, date: '2026-05-02'),
      ], '2026-05-01');
      expect(t.consumed, 800);
      expect(t.burned, 200);
      expect(t.net, 600);
      expect(t.protein, 30);
    });

    test('keeps the newest entry per name (case-insensitive)', () {
      final r = recentDistinct([
        e('Coffee', EntryType.meal, 5),
        e('coffee', EntryType.meal, 6),
        e('Run', EntryType.exercise, 300),
        e('Toast', EntryType.meal, 80),
      ], EntryType.meal);
      expect(r.map((x) => x.name), ['Coffee', 'Toast']);
    });
  });

  test('fmtNum renders like JS numbers', () {
    expect(fmtNum(165), '165');
    expect(fmtNum(3.6), '3.6');
    expect(fmtNum(0.25, maxDecimals: 2), '0.25');
    expect(fmtNum(2.0), '2');
    expect(fmtNum(-0.04), '0');
  });
}
