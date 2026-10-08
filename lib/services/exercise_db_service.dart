import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/catalog_items.dart';

/// wger (https://wger.de) — a free, open exercise database (no API key).
///
/// wger has no working per-query search endpoint, so the whole English catalog
/// (~842 exercises, ~5 MB of JSON) is fetched once, reduced to
/// {id, name, kcal/min} (~75 KB) and cached on disk for a week. Searches then
/// filter it locally. wger carries no calorie data, so the burn rate is
/// estimated from each exercise's category; the user fine-tunes the duration.
class ExerciseDbService {
  ExerciseDbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _ttl = Duration(days: 7);
  static const _fileName = 'wger_catalog.json';

  List<ExerciseItem> _catalog = const [];
  DateTime? _fetchedAt;
  Future<void>? _loading;

  bool get _fresh => _catalog.isNotEmpty && _fetchedAt != null && DateTime.now().difference(_fetchedAt!) < _ttl;

  /// Matches for [query], best first. Null when the catalog is unavailable
  /// (offline on first use, or wger unreachable) so the UI doesn't mistake
  /// "not loaded" for "no matches". [] means loaded and nothing matched.
  Future<List<ExerciseItem>?> search(String query) async {
    await _ensureCatalog();
    if (_catalog.isEmpty) return null;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final matches = _catalog.where((e) => e.name.toLowerCase().contains(q)).toList()
      ..sort((a, b) {
        final r = _rank(a.name, q) - _rank(b.name, q);
        return r != 0 ? r : a.name.length - b.name.length;
      });
    return matches.take(12).toList();
  }

  // Rank exact > prefix > word-start > substring so the best names surface first.
  static int _rank(String name, String q) {
    final n = name.toLowerCase();
    if (n == q) return 0;
    if (n.startsWith(q)) return 1;
    if (RegExp('\\b${RegExp.escape(q)}').hasMatch(n)) return 2;
    return 3;
  }

  // Concurrent callers share one load.
  Future<void> _ensureCatalog() {
    if (_fresh) return Future.value();
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    final file = await _cacheFile();
    // 1) Disk cache (also used as a stale fallback if the refresh fails).
    if (_catalog.isEmpty && await file.exists()) {
      try {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _catalog = (data['items'] as List).map((e) => ExerciseItem.fromJson(e as Map<String, dynamic>)).toList();
        _fetchedAt = DateTime.tryParse('${data['fetchedAt']}');
        if (_fresh) return;
      } catch (e) {
        debugPrint('wger cache unreadable: $e');
      }
    }

    // 2) Network: one request for the whole catalog.
    try {
      final res = await _client
          .get(
            Uri.parse('https://wger.de/api/v2/exerciseinfo/?language=2&limit=999&format=json'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) {
        debugPrint('wger exercise fetch failed: HTTP ${res.statusCode}');
        return;
      }
      // Parsing ~5 MB of JSON off the UI isolate keeps scrolling smooth.
      final items = await Isolate.run(() => _parseCatalog(res.bodyBytes));
      if (items.isEmpty) return;
      _catalog = items;
      _fetchedAt = DateTime.now();
      await file.writeAsString(
        jsonEncode({
          'fetchedAt': _fetchedAt!.toIso8601String(),
          'items': [for (final e in items) e.toJson()],
        }),
      );
    } catch (e) {
      debugPrint('wger exercise fetch error: $e');
    }
  }

  Future<File> _cacheFile() async => File('${(await getApplicationSupportDirectory()).path}/$_fileName');
}

const _categoryKcal = {
  'Cardio': 9.5,
  'Legs': 6.0,
  'Back': 6.0,
  'Chest': 5.5,
  'Shoulders': 5.0,
  'Arms': 4.5,
  'Abs': 4.5,
  'Calves': 4.5,
};
const _defaultKcal = 5.5;

List<ExerciseItem> _parseCatalog(Uint8List body) {
  final data = jsonDecode(utf8.decode(body));
  final results = (data is Map && data['results'] is List) ? data['results'] as List : const [];
  final seen = <String>{};
  final out = <ExerciseItem>[];
  for (final r in results.whereType<Map>()) {
    final category = r['category'] is Map ? '${(r['category'] as Map)['name'] ?? ''}' : '';
    final translations = r['translations'] is List ? r['translations'] as List : const [];
    final en = translations.whereType<Map>().where((t) => t['language'] == 2 && t['name'] != null).firstOrNull;
    final name = '${en?['name'] ?? ''}'.trim();
    if (name.isEmpty) continue;
    if (!seen.add(name.toLowerCase())) continue; // dedupe variants sharing a name
    out.add(
      ExerciseItem(id: 'wger-${r['id']}', name: name, caloriesPerMinute: _categoryKcal[category] ?? _defaultKcal),
    );
  }
  out.sort((a, b) => a.name.compareTo(b.name));
  return out;
}
