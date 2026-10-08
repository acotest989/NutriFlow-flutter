import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/goal.dart';
import '../models/log_entry.dart';
import '../models/profile.dart';

/// The last data synced from Supabase for one user.
class DataSnapshot {
  const DataSnapshot({required this.entries, required this.goal, required this.hydration, required this.profile});

  final List<LogEntry> entries;
  final Goal goal;
  final Map<String, double> hydration;
  final Profile? profile;

  Map<String, dynamic> toJson() => {
    'v': 1,
    'entries': [for (final e in entries) e.toRow()],
    'goal': goal.toRow(),
    'hydration': hydration,
    'profile': profile?.toRow(),
  };

  factory DataSnapshot.fromJson(Map<String, dynamic> j) => DataSnapshot(
    entries: [for (final r in j['entries'] as List) LogEntry.fromRow(r as Map<String, dynamic>)],
    goal: Goal.fromRow(j['goal'] as Map<String, dynamic>),
    hydration: {for (final e in (j['hydration'] as Map<String, dynamic>).entries) e.key: (e.value as num).toDouble()},
    profile: j['profile'] == null ? null : Profile.fromRow(j['profile'] as Map<String, dynamic>),
  );
}

/// Per-user JSON snapshot on disk so the app opens (and reads) offline.
/// Writes are best-effort: a failed cache write never affects the app.
class LocalCache {
  Future<File> _file(String userId) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/data_$userId.json');
  }

  Future<DataSnapshot?> read(String userId) async {
    try {
      final f = await _file(userId);
      if (!await f.exists()) return null;
      return DataSnapshot.fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Local cache unreadable: $e');
      return null;
    }
  }

  // Writes are chained so two quick saves can't race on the same temp file.
  Future<void> _pending = Future.value();

  Future<void> write(String userId, DataSnapshot snapshot) => _pending = _pending.then((_) => _write(userId, snapshot));

  Future<void> _write(String userId, DataSnapshot snapshot) async {
    try {
      final f = await _file(userId);
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
      await tmp.rename(f.path); // atomic replace: never leaves a half-written cache
    } catch (e) {
      debugPrint('Local cache write failed: $e');
    }
  }

  Future<void> clear(String userId) async {
    try {
      final f = await _file(userId);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
