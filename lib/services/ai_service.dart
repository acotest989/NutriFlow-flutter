import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;

import '../config.dart';
import '../core/ai_prefs.dart';
import '../models/catalog_items.dart';
import '../models/goal.dart';
import '../models/log_entry.dart';

enum AiErrorKind { busy, notConfigured, network, failed }

class AiException implements Exception {
  const AiException(this.kind, [this.detail]);
  final AiErrorKind kind;
  final Object? detail;

  @override
  String toString() => 'AiException($kind, $detail)';
}

class PhotoEstimate {
  const PhotoEstimate({
    required this.name,
    required this.items,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.note,
  });

  final String name;
  final List<String> items;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String note;

  bool get noFood => calories == 0 && items.isEmpty;
}

class Recipe {
  const Recipe({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    required this.difficulty,
    required this.summary,
    required this.instructions,
  });

  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int prepTime;
  final String difficulty;
  final String summary;
  final String instructions;
}

class CoachReview {
  const CoachReview({
    required this.grade,
    required this.summary,
    required this.suggestions,
    required this.streakMessage,
  });

  final String grade;
  final String summary;
  final List<String> suggestions;
  final String streakMessage;
}

/// Gemini through Firebase AI Logic. The API key never ships in the app:
/// Firebase proxies the calls and App Check (Play Integrity) proves the
/// requests come from the genuine app. Prompts mirror the web server's.
class AiService {
  static const _retriesPerModel = 2; // attempts per model = retries + 1
  static const _requestTimeout = Duration(seconds: 60);

  bool get _configured => Firebase.apps.isNotEmpty;

  // ---------- Public API ----------

  Future<FoodItem> estimateFood(String description, String lang) async {
    final json = await _generateJson(
      system:
          'You are a professional nutrition expert and dietitian. Analyze food and meal descriptions to provide accurate estimations for calories (kcal) and macronutrients in grams. Return values as a structured JSON object.',
      prompt: [
        TextPart(
          'Estimate the nutritional facts (calories, protein, carbs, fat, typical serving size, and serving unit) for the following food item or meal description: "$description". Provide the most realistic and accurate nutritional values possible.${_langText(lang)}',
        ),
      ],
      schema: _foodSchema(
        name: 'Clean, standardized title of the food or meal.',
        unit: "The serving unit (e.g., 'g', 'slice', 'cup', 'oz', 'bowl').",
      ),
    );
    return FoodItem.fromJson(json as Map<String, dynamic>, id: 'ai');
  }

  Future<FoodItem> estimateBarcode(String barcode, String lang) async {
    final json = await _generateJson(
      system:
          'You are a barcode nutrition interpreter. Identify products by barcode or generate a highly realistic product nutrition profile if the barcode is custom. Return values as a structured JSON object.',
      prompt: [
        TextPart(
          'Identify or realistically estimate the grocery item and nutritional facts for barcode/UPC/EAN numbers: "$barcode". If the barcode is real, identify it. If unknown, generate a highly realistic, typical grocery item (like protein bars, chips, soups, or snacks) and provide exact nutrients.${_langText(lang)}',
        ),
      ],
      schema: _foodSchema(
        name: 'Grocery product name and brand.',
        unit: "Serving unit (e.g., 'g', 'oz', 'bottle', 'bar').",
      ),
    );
    return FoodItem.fromJson(json as Map<String, dynamic>, id: 'ai-$barcode');
  }

  Future<PhotoEstimate> analyzePhoto(Uint8List image, String mimeType, String lang) async {
    final json =
        await _generateJson(
              system:
                  'You are a nutrition vision expert. You estimate calories and macronutrients from meal photos. Be realistic and concise, and always return a single structured JSON object describing the whole plate.',
              prompt: [
                TextPart(
                  "Analyze this meal photo. Identify the distinct food and drink items visible, then estimate the TOTAL nutrition for everything shown as a single meal. Assume typical single-serving portions when the size is ambiguous, and give realistic values. If the photo contains no food, set name to 'No food detected', items to an empty array, and every number to 0.${_langText(lang)}",
                ),
                InlineDataPart(mimeType, image),
              ],
              schema: Schema.object(
                properties: {
                  'name': Schema.string(
                    description: "Short name for the whole meal, e.g. 'Grilled chicken with rice and salad'.",
                  ),
                  'items': Schema.array(
                    items: Schema.string(),
                    description: 'The distinct foods/drinks detected in the photo.',
                  ),
                  'calories': Schema.integer(description: 'Total energy for the plate in kcal.'),
                  'protein': Schema.number(description: 'Total protein in grams.'),
                  'carbs': Schema.number(description: 'Total carbohydrates in grams.'),
                  'fat': Schema.number(description: 'Total fat in grams.'),
                  'note': Schema.string(description: "One short caveat about portion/assumptions, or '' if none."),
                },
                optionalProperties: ['note'],
              ),
            )
            as Map<String, dynamic>;

    final items = (json['items'] is List)
        ? (json['items'] as List).map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    final name = '${json['name'] ?? ''}'.trim();
    return PhotoEstimate(
      name: name.isEmpty ? 'Meal' : name,
      items: items,
      calories: math.max(0, _num(json['calories']).roundToDouble()),
      protein: math.max(0, _num(json['protein'])),
      carbs: math.max(0, _num(json['carbs'])),
      fat: math.max(0, _num(json['fat'])),
      note: '${json['note'] ?? ''}'.trim(),
    );
  }

  Future<List<Recipe>> generateRecipes(String ingredients, AiPrefs? prefs, String lang) async {
    final json = await _generateJson(
      system:
          'You are a professional chef and sports nutritionist. Create exactly 3 fitness-friendly recipes using provided ingredients. Return a structured JSON array.',
      prompt: [
        TextPart(
          'Based on these ingredients available: "$ingredients", generate 3 distinct, delicious, healthy recipe recommendations. Calculate exact nutritional values (calories, protein, carbs, fat) and specify instructions, preparation time (mins), and difficulty.${prefs?.toPromptText() ?? ''} IMPORTANT: every recipe MUST comply with the user\'s dietary preference and MUST NOT contain any of their restricted/allergen ingredients; lean the recipes toward their goal.${_langText(lang)}',
        ),
      ],
      schema: Schema.array(
        items: Schema.object(
          properties: {
            'name': Schema.string(description: 'Name of the recipe'),
            'calories': Schema.integer(description: 'Estimated kcal'),
            'protein': Schema.number(description: 'Protein in grams'),
            'carbs': Schema.number(description: 'Carbohydrates in grams'),
            'fat': Schema.number(description: 'Fat in grams'),
            'prepTime': Schema.integer(description: 'Preparation & cooking time in minutes'),
            'difficulty': Schema.string(description: 'Easy, Medium, or Hard'),
            'summary': Schema.string(description: 'A brief appetizing sentence about the recipe.'),
            'instructions': Schema.string(description: 'Concise step-by-step instructions (plain text).'),
          },
        ),
      ),
    );
    if (json is! List) {
      throw const AiException(AiErrorKind.failed, 'Expected a JSON array');
    }
    return [
      for (final r in json.whereType<Map<String, dynamic>>())
        Recipe(
          name: '${r['name'] ?? ''}',
          calories: _num(r['calories']),
          protein: _num(r['protein']),
          carbs: _num(r['carbs']),
          fat: _num(r['fat']),
          prepTime: _num(r['prepTime']).round(),
          difficulty: '${r['difficulty'] ?? ''}',
          summary: '${r['summary'] ?? ''}',
          instructions: '${r['instructions'] ?? ''}',
        ),
    ];
  }

  Future<CoachReview> coachReview({
    required List<LogEntry> entries,
    required Goal goal,
    required String date,
    required AiPrefs? prefs,
    required String lang,
  }) async {
    final logs = [
      for (final e in entries)
        {
          'type': e.type.name,
          'name': e.name,
          'calories': e.calories,
          'protein': e.protein,
          'carbs': e.carbs,
          'fat': e.fat,
          'quantity': e.quantity,
        },
    ];
    final json =
        await _generateJson(
              system:
                  'You are a friendly, motivational, high-performance athletic diet coach. Evaluate user logs and give professional structured feedback including a letter grade (e.g. A, B+, C), a 2-3 sentence motivational summary, and 3 specific, actionable nutrition or workout suggestions.',
              prompt: [
                TextPart(
                  'Analyze the logged diet and exercise entries for date "$date".\n'
                  'Current Daily Goals: ${jsonEncode(goal.toRow())}.\n'
                  'Daily Logs: ${jsonEncode(logs)}.${prefs?.toPromptText() ?? ''}\n\n'
                  "Evaluate their calorie balance (consumed vs. burned), macronutrient balance (protein, carbs, fat target vs actual), and physical activity. Give a constructive analysis. Tailor your summary and the 3 suggestions to the user's profile above — align advice with their goal, respect their dietary preference, never suggest foods that conflict with their restrictions/allergies, and prefer their favored workout types.${_langText(lang)}",
                ),
              ],
              schema: Schema.object(
                properties: {
                  'grade': Schema.string(description: 'Overall letter grade (e.g., A+, B-, C)'),
                  'summary': Schema.string(
                    description: "A highly motivating, friendly summary analysis of the day's intake and workout.",
                  ),
                  'suggestions': Schema.array(
                    items: Schema.string(),
                    description:
                        "Three highly actionable suggestions (e.g., 'Hydrate more', 'Add 15g protein to breakfast', 'Increase rest between HIIT sets').",
                  ),
                  'streakMessage': Schema.string(description: 'A fun booster message encouraging their progress.'),
                },
              ),
            )
            as Map<String, dynamic>;
    return CoachReview(
      grade: '${json['grade'] ?? '?'}',
      summary: '${json['summary'] ?? ''}',
      suggestions: (json['suggestions'] is List) ? (json['suggestions'] as List).map((e) => '$e').toList() : const [],
      streakMessage: '${json['streakMessage'] ?? ''}',
    );
  }

  // ---------- Internals ----------

  Schema _foodSchema({required String name, required String unit}) => Schema.object(
    properties: {
      'name': Schema.string(description: name),
      'calories': Schema.integer(description: 'Estimated energy content in kcal.'),
      'protein': Schema.number(description: 'Estimated protein in grams.'),
      'carbs': Schema.number(description: 'Estimated total carbohydrates in grams.'),
      'fat': Schema.number(description: 'Estimated total fat in grams.'),
      'servingSize': Schema.integer(description: 'Estimated typical serving size number (e.g. 1, 100, 200).'),
      'servingUnit': Schema.string(description: unit),
    },
  );

  static const _langNames = {
    'sr': 'Serbian (ekavian dialect, Latin script — no Cyrillic)',
    'hr': 'Croatian',
    'bs': 'Bosnian',
  };

  /// Ask the model to write human-readable output in the user's language.
  String _langText(String lang) {
    final name = _langNames[lang];
    if (name == null) return '';
    return ' IMPORTANT: Write every human-readable text field (names, summaries, notes, suggestions, instructions, messages) in $name, using natural native phrasing. Keep numbers and measurement units (g, kcal, ml) unchanged.';
  }

  /// Call Gemini and parse its JSON response. Retries transient failures with
  /// exponential backoff + jitter, then falls back to the next model in the
  /// chain (same policy as the web server's generateJSON).
  Future<Object?> _generateJson({required String system, required List<Part> prompt, required Schema schema}) async {
    if (!_configured) throw const AiException(AiErrorKind.notConfigured);

    final ai = FirebaseAI.googleAI();
    final models = AppConfig.geminiModels;
    Object? lastErr;
    Object? transientErr; // remembered so "AI is busy" wins over a bad-fallback 404
    final rnd = math.Random();

    for (var m = 0; m < models.length; m++) {
      final isLastModel = m == models.length - 1;
      final model = ai.generativeModel(
        model: models[m],
        systemInstruction: Content.system(system),
        generationConfig: GenerationConfig(responseMimeType: 'application/json', responseSchema: schema),
      );

      for (var attempt = 0; attempt <= _retriesPerModel; attempt++) {
        try {
          final res = await model.generateContent([Content.multi(prompt)]).timeout(_requestTimeout);
          final text = res.text;
          if (text == null || text.trim().isEmpty) {
            throw const FormatException('No response text received from Gemini.');
          }
          return jsonDecode(text.trim());
        } catch (err) {
          if (_isNetwork(err)) throw AiException(AiErrorKind.network, err);
          lastErr = err;
          if (_isTransient(err)) transientErr = err;
          final retryable = _isRetryable(err);
          debugPrint('Gemini ${models[m]} attempt $attempt failed: $err');

          if (attempt < _retriesPerModel && retryable) {
            final backoff = 400 * math.pow(3, attempt).toInt() + rnd.nextInt(250);
            await Future<void>.delayed(Duration(milliseconds: backoff));
            continue;
          }
          if (!isLastModel && (retryable || _isModelUnavailable(err))) {
            break; // next model
          }
          throw _toAiException(transientErr ?? err);
        }
      }
    }
    throw _toAiException(transientErr ?? lastErr);
  }

  AiException _toAiException(Object? err) {
    if (err is AiException) return err;
    if (_isTransient(err)) return AiException(AiErrorKind.busy, err);
    if (err is InvalidApiKey || err is ServiceApiNotEnabled) {
      return AiException(AiErrorKind.notConfigured, err);
    }
    return AiException(AiErrorKind.failed, err);
  }

  static bool _isNetwork(Object err) =>
      err is SocketException || err is HandshakeException || err is HttpException || err is ClientException;

  static bool _isTransient(Object? err) {
    if (err == null) return false;
    if (err is QuotaExceeded || err is TimeoutException) return true;
    final msg = '$err';
    return msg.contains('503') ||
        msg.contains('UNAVAILABLE') ||
        msg.contains('overloaded') ||
        msg.contains('429') ||
        msg.contains('RESOURCE_EXHAUSTED') ||
        msg.contains('500') ||
        msg.contains('INTERNAL') ||
        msg.contains('DEADLINE');
  }

  // A truncated/empty/garbled response is often transient too — worth one more shot.
  static bool _isRetryable(Object err) => _isTransient(err) || err is FormatException;

  // A model that doesn't exist / isn't enabled. Lets us skip a bad fallback entry.
  static bool _isModelUnavailable(Object err) {
    final msg = '$err';
    return msg.contains('404') ||
        msg.contains('NOT_FOUND') ||
        msg.contains('not found') ||
        msg.contains('not supported');
  }
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
