import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

// When a logged-out visitor completes the promo quiz, their answers are stashed
// here and applied automatically on their first sign-in (AppController.loadData).
const _key = 'nutriflow-pending-onboarding';

Future<void> stashPendingOnboarding(SharedPreferences prefs, OnboardingData d) =>
    prefs.setString(_key, jsonEncode(d.toRow()));

OnboardingData? readPendingOnboarding(SharedPreferences prefs) {
  try {
    final s = prefs.getString(_key);
    return s == null ? null : OnboardingData.fromRow(jsonDecode(s) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

Future<void> clearPendingOnboarding(SharedPreferences prefs) => prefs.remove(_key);
