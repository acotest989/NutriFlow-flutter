# NutriFlow (Flutter / Android)

Native Android rewrite of [NutriFlow](../NutriFlow) — diet, hydration and exercise tracker. It replaces the
Trusted Web Activity on Google Play (same package `app.nutriflow.twa`, same upload key), so existing installs
update in place. No WebView and no own backend: the app talks directly to Supabase, Firebase AI Logic,
Open Food Facts, USDA FoodData Central and wger.

| Concern | Web app (TWA) | Flutter app |
|---|---|---|
| Auth + data | Supabase (browser) | Supabase (`supabase_flutter`), same project + schema |
| Gemini AI | Express proxy on Cloud Run | **Firebase AI Logic** (`firebase_ai`) + App Check (Play Integrity) — key never in the APK |
| Account deletion | `DELETE /api/account` (service role) | `delete_own_account()` RPC (security definer, migration `0005`) |
| Barcode | `BarcodeDetector` + server → Open Food Facts | `mobile_scanner` (ML Kit) → Open Food Facts direct |
| Food search | server → USDA | USDA direct (`FDC_API_KEY`, optional) |
| Exercise search | server-side wger cache | wger catalog downloaded once, cached on device 7 days |
| Google sign-in | OAuth redirect | Native Credential Manager (`google_sign_in`) → `signInWithIdToken` |
| Offline | PWA app shell | Last synced data cached per user on disk; writes need a connection |

Features are the same as the web: onboarding quiz (Mifflin–St Jeor goal), dashboard + calorie ring + macros,
hydration, meals (catalog / USDA / recent / manual / AI estimate), workouts (presets / wger / recent / custom),
AI coach + AI chef, Snap-a-Meal photo analysis, barcode scanner, 7-day trend chart, streaks + badges,
EN / SR / HR / BS, dark + high-contrast light theme, reset data, delete account.

## Project layout

```
lib/
  main.dart, app.dart        bootstrap (Supabase, Firebase, prefs) + auth/onboarding gate, toast, offline banner
  config.dart                build-time config (public Supabase values + --dart-define keys)
  core/                      pure logic: goal math, streaks, local-date helpers, totals, AI prefs
  models/                    LogEntry, Goal, Profile/OnboardingData, FoodItem/ExerciseItem
  data/catalog.dart          58 foods + 21 workouts (same as the web's src/data.ts)
  services/                  Gemini (Firebase AI), Open Food Facts + USDA, wger, local cache
  state/                     Riverpod: AppController (port of the web store), settings (theme/language)
  ui/                        theme (both web themes), shared widgets, screens + tabs
  l10n/                      app_{en,sr,hr,bs}.arb (converted from the web locales) + generated code
test/                        unit tests (goal, streaks, dates) + screenshots/ (visual review, opt-in)
```

## Run

```
copy config.example.json config.json      # fill in what you have; empty values are fine
flutter run --dart-define-from-file=config.json
flutter test                              # unit tests
flutter analyze
```

`config.json` (gitignored):
- `GOOGLE_WEB_CLIENT_ID` — the **Web** OAuth client ID already used by the Supabase Google provider. Without it the
  Google button shows "not set up".
- `FDC_API_KEY` — USDA key (same as Cloud Run's). Without it food search uses the in-app catalog only.

Screens with demo data (no login needed): `flutter test --tags screenshots --run-skipped --update-goldens` →
`test/screenshots/goldens/*.png`.

## One-time setup

### 1. Supabase
- Run `supabase/migrations/0005_delete_own_account.sql` (in the NutriFlow repo) in the SQL Editor.
- Authentication → URL Configuration → Redirect URLs: add `app.nutriflow.twa://login-callback`
  (email confirmation + password reset open the app).

### 2. Firebase (AI features)
1. Firebase console → Add project → pick the existing Google Cloud project (the one Cloud Run uses).
2. `dart pub global activate flutterfire_cli`, then in this folder: `flutterfire configure --platforms=android`
   (overwrites the placeholder `lib/firebase_options.dart`).
3. Firebase console → **AI Logic** → Get started → Gemini Developer API.
4. **App Check** → Android app → Play Integrity (SHA-256 of the Play app-signing key, from Play Console → App
   integrity). Debug builds log a debug token in logcat — add it under App Check → Manage debug tokens.
   Turn on enforcement for AI Logic once real traffic shows as verified.

Until this is done the app runs normally and the AI features show "AI features aren't available".

### 3. Google sign-in (Android)
Google Cloud console → APIs & Services → Credentials → Create OAuth client ID → **Android**, package
`app.nutriflow.twa`, one client per SHA-1:
- Play app-signing key (Play Console → App integrity),
- upload key: `keytool -list -v -keystore ../NutriFlow/play-package/signing.keystore -alias my-key-alias`,
- debug key: `keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android`.

No change in Supabase is needed — the ID token's audience is the existing Web client.

### 4. Release signing
`copy android\key.properties.example android\key.properties` and fill in the passwords (gitignored). It points at the
TWA's upload keystore `../NutriFlow/play-package/signing.keystore`.

## Release to Google Play
1. Bump `version:` in `pubspec.yaml` (`name+code`; the TWA ended at 1.0.3+4, this starts at 2.0.0+5).
2. `flutter build appbundle --release --dart-define-from-file=config.json`
3. Upload `build/app/outputs/bundle/release/app-release.aab`.
4. Play Console → Data safety: data is now also processed by Google Firebase (AI requests, photos for Snap-a-Meal)
   and the app requests the camera permission.

Launcher icon / splash: `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`
(sources in `assets/icons/`).
