/// Build-time configuration.
///
/// Public values (Supabase URL + publishable key) have defaults so a plain
/// `flutter run` works. Private/optional values come from
/// `--dart-define-from-file=config.json` (see `config.example.json`).
class AppConfig {
  AppConfig._();

  /// Public Supabase project — same project as the web app. Row-Level Security
  /// protects the data, so these are safe to ship in the APK.
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xwblliudqnzhzmulyuyk.supabase.co',
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_ReASdH2ojGBhH8mjOCoO1A_OpEKixnV',
  );

  /// OAuth client ID of the *Web application* client used by the Supabase
  /// Google provider. Native Google sign-in needs it as `serverClientId` so the
  /// ID token's audience matches what Supabase verifies.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// USDA FoodData Central key for the online food search. Optional — without
  /// it the food search uses the in-app catalog only.
  static const fdcApiKey = String.fromEnvironment('FDC_API_KEY');

  /// Gemini model fallback chain (primary first), called through Firebase AI
  /// Logic. If the primary is overloaded the next one is tried.
  static const geminiModels = ['gemini-3.5-flash', 'gemini-2.5-flash'];

  /// Deep link Supabase redirects to after email confirmation / password reset.
  /// Must be listed under Supabase → Authentication → URL Configuration.
  static const authRedirectUrl = 'app.nutriflow.twa://login-callback';

  static const privacyUrl = 'https://nutriflow-623241712044.europe-west1.run.app/privacy';
  static const contactEmail = 'chillibrimedia@gmail.com';
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=app.nutriflow.twa';
}
