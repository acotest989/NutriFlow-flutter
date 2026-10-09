// Renders the main screens with demo data into PNGs (test/screenshots/goldens/)
// for visual review and store screenshots. Not part of the regular suite:
//   flutter test --tags screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'package:flutter/material.dart' show SingleChildScrollView;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow/app.dart';
import 'package:nutriflow/core/date_utils.dart';
import 'package:nutriflow/models/goal.dart';
import 'package:nutriflow/models/log_entry.dart';
import 'package:nutriflow/models/profile.dart';
import 'package:nutriflow/state/app_controller.dart';
import 'package:nutriflow/state/providers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _DemoApp extends AppController {
  _DemoApp(this.fixture);
  final AppState fixture;

  @override
  AppState build() => fixture;
}

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();
  final mono = FontLoader('JetBrainsMono');
  for (final w in ['Regular', 'Medium', 'Bold']) {
    mono.addFont(rootBundle.load('assets/fonts/JetBrainsMono-$w.ttf'));
  }
  await mono.load();
  await (FontLoader(
    'packages/lucide_icons_flutter/Lucide',
  )..addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'))).load();
}

AppState _fixture() {
  final today = todayStr();
  var n = 0;
  LogEntry e(int daysAgo, EntryType type, String name, double cal, [double p = 0, double c = 0, double f = 0, double q = 100]) =>
      LogEntry(
        id: 'e${n++}',
        date: addDays(today, -daysAgo),
        type: type,
        name: name,
        calories: cal,
        protein: p,
        carbs: c,
        fat: f,
        quantity: q,
        timestamp: '',
      );
  final meal = EntryType.meal, ex = EntryType.exercise;
  final entries = [
    e(0, meal, 'Greek Yogurt & Honey', 220, 16, 28, 4, 200),
    e(0, meal, 'Grilled Chicken Breast (x1.5)', 248, 46.5, 0, 5.4, 150),
    e(0, meal, 'Ćevapi (10 pcs) (x1)', 375, 26, 3, 29, 150),
    e(0, ex, 'Running (Moderate Pace) (30 mins)', 342, 0, 0, 0, 30),
    for (var d = 1; d <= 9; d++) ...[
      e(d, meal, 'Oatmeal (Cooked in Water) (x2)', 142 + d * 40.0, 5, 24, 3),
      e(d, meal, 'Burek (Meat) (x1)', 560, 18, 45, 35),
      e(d, meal, 'Salmon Fillet (Baked) (x1)', 206 + d * 25.0, 22, 0, 12),
      if (d.isEven) e(d, ex, 'HIIT Workout (30 mins)', 405, 0, 0, 0, 30),
    ],
  ];
  const profile = Profile(
    goalType: GoalType.lose,
    sex: Sex.male,
    age: 31,
    heightCm: 180,
    weightKg: 82,
    targetWeightKg: 76,
    activity: ActivityLevel.moderate,
    diet: DietPreference.highProtein,
    restrictions: ['Nuts'],
    workouts: ['Running', 'HIIT'],
    units: Units.metric,
    hasOnboarded: true,
  );
  final user = const User(
    id: 'demo',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00Z',
    email: 'demo@nutriflow.app',
  );
  return AppState.initial(Session(accessToken: 'demo', tokenType: 'bearer', user: user)).copyWith(
    entries: entries,
    goal: const Goal(calories: 2210, protein: 165, carbs: 205, fat: 65),
    hydration: {today: 1250, for (var d = 1; d <= 8; d++) addDays(today, -d): 2000},
    profile: profile,
    hasOnboarded: true,
  );
}

Future<void> _pumpApp(WidgetTester tester, {Map<String, Object> prefs = const {}, AppState? state}) async {
  SharedPreferences.setMockInitialValues(prefs);
  PackageInfo.setMockInitialValues(
    appName: 'NutriFlow',
    packageName: 'app.nutriflow.twa',
    version: '2.0.0',
    buildNumber: '5',
    buildSignature: '',
  );
  final sp = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(sp),
        onlineProvider.overrideWith((ref) => Stream.value(true)),
        appProvider.overrideWith(() => _DemoApp(state ?? _fixture())),
      ],
      child: const NutriFlowApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 2));
  await expectLater(find.byType(NutriFlowApp), matchesGoldenFile('goldens/$name.png'));
}

/// Phone-sized capture for the README (docs/screenshots/, committed).
Future<void> _readme(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 2));
  await expectLater(find.byType(NutriFlowApp), matchesGoldenFile('../../docs/screenshots/$name.png'));
}

/// A real phone viewport (412 × 915 dp) instead of the tall review canvas.
void _phoneView() {
  final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
  view.physicalSize = const Size(412 * 2.5, 915 * 2.5);
  view.devicePixelRatio = 2.5;
  view.padding = const FakeViewPadding(top: 60, bottom: 40);
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpAll(_loadFonts);

  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    // Phone width (412 dp) and tall enough to show each tab's full content.
    view.physicalSize = const Size(412 * 2, 2400 * 2);
    view.devicePixelRatio = 2;
    view.padding = const FakeViewPadding(top: 48, bottom: 32);
  });

  testWidgets('tabs (dark, English)', (tester) async {
    await _pumpApp(tester);
    await _shot(tester, 'dashboard');
    await _tab(tester, 'Meals');
    await _shot(tester, 'meals');
    await _tab(tester, 'Active');
    await _shot(tester, 'exercise');
    await _tab(tester, 'AI Coach');
    await _shot(tester, 'coach');
    await _tab(tester, 'Trends');
    await _shot(tester, 'trends');
    await _tab(tester, 'UPC Scan');
    await _shot(tester, 'scan');
  });

  testWidgets('dashboard (light, Bosnian)', (tester) async {
    await _pumpApp(tester, prefs: {'nutriflow-theme': 'light', 'nutriflow-lang': 'bs'});
    await _shot(tester, 'dashboard_light_bs');
    await _tab(tester, 'Trendovi');
    await _shot(tester, 'trends_light_bs');
  });

  testWidgets('first-run onboarding', (tester) async {
    await _pumpApp(tester, state: _fixture().copyWith(hasOnboarded: false, profile: null));
    await _shot(tester, 'onboarding');
  });

  testWidgets('README screenshots (phone size)', (tester) async {
    _phoneView();
    await _pumpApp(tester);
    await _readme(tester, 'dashboard');
    await _tab(tester, 'Meals');
    await _readme(tester, 'meals');
    await _tab(tester, 'Trends');
    // Scroll past the streak + badges to the 7-day chart.
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -760));
    await _readme(tester, 'trends');
    await _tab(tester, 'UPC Scan');
    await _readme(tester, 'scan');
  });

  testWidgets('README screenshot (light, Bosnian)', (tester) async {
    _phoneView();
    await _pumpApp(tester, prefs: {'nutriflow-theme': 'light', 'nutriflow-lang': 'bs'});
    await _readme(tester, 'dashboard_light_bs');
  });
}
