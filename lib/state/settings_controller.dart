import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// "Deep Midnight" (dark) and "High Contrast Light" — the web app's two themes.
enum AppTheme { dark, light }

class AppLanguage {
  const AppLanguage(this.code, this.label, this.short);
  final String code;
  final String label;
  final String short;
}

const appLanguages = [
  AppLanguage('en', 'English', 'EN'),
  AppLanguage('sr', 'Srpski', 'SR'),
  AppLanguage('hr', 'Hrvatski', 'HR'),
  AppLanguage('bs', 'Bosanski', 'BS'),
];

bool isSupportedLanguage(String? code) => appLanguages.any((l) => l.code == code);

/// Locale for formatting dates/numbers (intl). Serbian is Latin-only.
String intlLocale(String code) => switch (code) {
  'sr' => 'sr_Latn',
  'hr' => 'hr',
  'bs' => 'bs',
  _ => 'en_US',
};

/// Flutter Locale for MaterialApp. Serbian carries the Latin script code so the
/// built-in Material strings aren't Cyrillic.
Locale flutterLocale(String code) =>
    code == 'sr' ? const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn') : Locale(code);

class Settings {
  const Settings({required this.theme, required this.language});
  final AppTheme theme;
  final String language;

  Settings copyWith({AppTheme? theme, String? language}) =>
      Settings(theme: theme ?? this.theme, language: language ?? this.language);
}

/// Device-local UI preferences (theme + language), persisted in
/// SharedPreferences. The language is also synced to the profile by
/// AppController.updateLanguage.
class SettingsController extends Notifier<Settings> {
  static const _themeKey = 'nutriflow-theme';
  static const _langKey = 'nutriflow-lang';

  @override
  Settings build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final storedLang = prefs.getString(_langKey);
    final deviceLang = PlatformDispatcher.instance.locale.languageCode;
    final language = isSupportedLanguage(storedLang)
        ? storedLang!
        : isSupportedLanguage(deviceLang)
        ? deviceLang
        : 'en';
    final theme = prefs.getString(_themeKey) == 'light' ? AppTheme.light : AppTheme.dark;
    return Settings(theme: theme, language: language);
  }

  void toggleTheme() {
    final next = state.theme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    state = state.copyWith(theme: next);
    ref.read(sharedPrefsProvider).setString(_themeKey, next.name);
  }

  /// Apply a language locally (tolerates unknown codes from the DB — no-op).
  void setLanguage(String code) {
    if (!isSupportedLanguage(code) || code == state.language) return;
    state = state.copyWith(language: code);
    ref.read(sharedPrefsProvider).setString(_langKey, code);
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(SettingsController.new);
