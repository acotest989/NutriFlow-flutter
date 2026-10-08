import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status + navigation bars on every Android version (it's
  // only the default from Android 15); screens pad themselves via SafeArea.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await initializeDateFormatting();
  await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabasePublishableKey);
  await _initFirebase();
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(overrides: [sharedPrefsProvider.overrideWithValue(prefs)], child: const NutriFlowApp()));
}

/// Firebase powers the AI features only (Firebase AI Logic + App Check). If
/// it isn't configured the rest of the app still works.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAppCheck.instance.activate(
      // Debug builds print a debug token to logcat; register it in the
      // Firebase console (App Check → Manage debug tokens) to test AI locally.
      providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
    );
  } catch (e) {
    debugPrint('Firebase unavailable — AI features disabled: $e');
  }
}
