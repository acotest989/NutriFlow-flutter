import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import '../state/app_controller.dart';

/// Localized message for an [AppError].
String appErrorText(AppLocalizations t, AppError e) => switch (e.kind) {
  ErrorKind.loadData => t.errLoadData,
  ErrorKind.saveEntry => t.errSaveEntry,
  ErrorKind.deleteEntry => t.errDeleteEntry,
  ErrorKind.saveGoal => t.errSaveGoal,
  ErrorKind.saveWater => t.errSaveWater,
  ErrorKind.notSignedIn => t.errNotSignedIn,
  ErrorKind.saveProfile => t.errSaveProfile,
  ErrorKind.resetData => t.errResetData,
  ErrorKind.deleteAccount => t.errDeleteAccount,
  ErrorKind.network => t.errNetwork,
  ErrorKind.googleNotConfigured => t.errGoogleNotConfigured,
  ErrorKind.googleFailed => t.errGoogleFailed,
  ErrorKind.generic => t.errGeneric,
  ErrorKind.raw => e.message ?? t.errGeneric,
};

/// Localized message for an AI failure; [fallback] is the screen's own
/// "couldn't do X" text for non-specific failures.
String aiErrorText(AppLocalizations t, Object error, String fallback) {
  if (error is! AiException) return fallback;
  return switch (error.kind) {
    AiErrorKind.busy => t.errAiBusy,
    AiErrorKind.notConfigured => t.errAiNotConfigured,
    AiErrorKind.network => t.errNetwork,
    AiErrorKind.failed => fallback,
  };
}
