import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../core/format.dart';
import '../models/catalog_items.dart';
import 'ai_service.dart';

/// Online food sources called directly from the app (no own backend):
/// Open Food Facts for barcodes and USDA FoodData Central for text search.
class FoodDbService {
  FoodDbService({http.Client? client, required this.ai}) : _client = client ?? http.Client();

  final http.Client _client;
  final AiService ai;

  static const _userAgent = 'NutriFlow-Android/1.0 (${AppConfig.contactEmail})';

  /// Barcode lookup chain: Open Food Facts → known demo codes → AI estimate.
  Future<FoodItem> lookupBarcode(String barcode, String lang) async {
    final code = barcode.trim();
    final off = await _openFoodFacts(code);
    if (off != null) return off;
    final demo = _demoBarcodes[code];
    if (demo != null) return demo;
    return ai.estimateBarcode(code, lang);
  }

  /// Real product by barcode from Open Food Facts (free, no key). Null when not
  /// found / no usable data / network error, so the caller can fall back.
  Future<FoodItem?> _openFoodFacts(String barcode) async {
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/${Uri.encodeComponent(barcode)}.json'
      '?fields=product_name,brands,nutriments,serving_quantity',
    );
    try {
      final res = await _client.get(uri, headers: {'User-Agent': _userAgent}).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is! Map || data['status'] != 1 || data['product'] is! Map) return null;

      final p = data['product'] as Map;
      final n = (p['nutriments'] is Map) ? p['nutriments'] as Map : const {};
      // Clean "Product · Brand" name. OFF's `brands` is a messy comma list, so
      // take the first brand and skip it if the product name already has it.
      final productName = '${p['product_name'] ?? ''}'.trim();
      final firstBrand = '${p['brands'] ?? ''}'.split(',').first.trim();
      final name = firstBrand.isNotEmpty && !productName.toLowerCase().contains(firstBrand.toLowerCase())
          ? '$productName · $firstBrand'
          : productName;
      if (name.isEmpty) return null;

      final servingQ = _num(p['serving_quantity']);
      // Prefer per-serving values when a serving size is known; else per 100 g.
      final perServing = n['energy-kcal_serving'] != null && servingQ > 0;
      final cal = perServing ? n['energy-kcal_serving'] : n['energy-kcal_100g'];
      if (cal == null) return null;

      double pick(String key) => round1(_num(perServing ? n['${key}_serving'] : n['${key}_100g']));
      return FoodItem(
        id: 'off-$barcode',
        name: name,
        calories: _num(cal).roundToDouble(),
        protein: pick('proteins'),
        carbs: pick('carbohydrates'),
        fat: pick('fat'),
        servingSize: perServing ? servingQ.roundToDouble() : 100,
        servingUnit: 'g',
      );
    } catch (e) {
      debugPrint('Open Food Facts lookup failed: $e');
      return null;
    }
  }

  /// USDA FoodData Central text search (generic foods, values per 100 g).
  /// Returns [] when no key is configured, nothing matches, or on error — the
  /// UI keeps its local catalog either way. Null signals a network failure so
  /// the UI doesn't claim "no matches".
  Future<List<FoodItem>?> searchUsda(String query) async {
    if (AppConfig.fdcApiKey.isEmpty) return const [];
    final uri = Uri.parse(
      'https://api.nal.usda.gov/fdc/v1/foods/search?api_key=${Uri.encodeComponent(AppConfig.fdcApiKey)}',
    );
    try {
      final res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': query,
              'pageSize': 10,
              // Generic whole foods; branded/barcode is covered by Open Food Facts.
              'dataType': ['Foundation', 'SR Legacy', 'Survey (FNDDS)'],
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        debugPrint('USDA food search failed: HTTP ${res.statusCode}');
        return null;
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final foods = (data is Map && data['foods'] is List) ? data['foods'] as List : const [];

      double? nutrient(List list, int id) {
        for (final x in list) {
          if (x is Map && x['nutrientId'] == id && x['value'] is num) return (x['value'] as num).toDouble();
        }
        return null;
      }

      // Generic FDC descriptions are often ALL CAPS — title-case those.
      String clean(String s) {
        final t = s.trim();
        if (t.isEmpty || t != t.toUpperCase()) return t;
        return t.toLowerCase().replaceAllMapped(RegExp(r'\b\w'), (m) => m[0]!.toUpperCase());
      }

      final out = <FoodItem>[];
      for (final f in foods.whereType<Map>()) {
        final list = f['foodNutrients'] is List ? f['foodNutrients'] as List : const [];
        // 1008 = Energy (kcal); 2047/2048 = Atwater energy fallbacks.
        final cal = nutrient(list, 1008) ?? nutrient(list, 2048) ?? nutrient(list, 2047);
        final name = clean('${f['description'] ?? ''}');
        if (cal == null || name.isEmpty) continue;
        out.add(
          FoodItem(
            id: 'usda-${f['fdcId']}',
            name: name,
            calories: cal.roundToDouble(),
            protein: round1(nutrient(list, 1003) ?? 0),
            carbs: round1(nutrient(list, 1005) ?? 0),
            fat: round1(nutrient(list, 1004) ?? 0),
            servingSize: 100,
            servingUnit: 'g',
          ),
        );
        if (out.length >= 8) break;
      }
      return out;
    } catch (e) {
      debugPrint('USDA food search error: $e');
      return null;
    }
  }

  // Known demo barcodes — instant fallback when Open Food Facts has no match.
  static const _demoBarcodes = {
    '49000000443': FoodItem(
      id: 'demo-1',
      name: 'Coca-Cola Classic (12 oz)',
      calories: 140,
      protein: 0,
      carbs: 39,
      fat: 0,
      servingSize: 355,
      servingUnit: 'ml',
    ),
    '070569005077': FoodItem(
      id: 'demo-2',
      name: 'Rolled Oats (1/2 cup)',
      calories: 150,
      protein: 5,
      carbs: 27,
      fat: 3,
      servingSize: 40,
      servingUnit: 'g',
    ),
    '011110038364': FoodItem(
      id: 'demo-3',
      name: 'Greek Yogurt - Plain Non-Fat',
      calories: 80,
      protein: 15,
      carbs: 6,
      fat: 0,
      servingSize: 150,
      servingUnit: 'g',
    ),
    '021130070519': FoodItem(
      id: 'demo-4',
      name: 'Whole Wheat Bread (1 Slice)',
      calories: 70,
      protein: 4,
      carbs: 12,
      fat: 1,
      servingSize: 28,
      servingUnit: 'g',
    ),
    '074570610053': FoodItem(
      id: 'demo-5',
      name: 'Whey Protein Powder (1 Scoop)',
      calories: 120,
      protein: 24,
      carbs: 3,
      fat: 1.5,
      servingSize: 32,
      servingUnit: 'g',
    ),
  };
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
