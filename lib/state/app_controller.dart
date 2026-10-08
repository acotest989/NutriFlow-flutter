import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../core/date_utils.dart';
import '../core/goal_calc.dart';
import '../core/pending_onboarding.dart';
import '../models/goal.dart';
import '../models/log_entry.dart';
import '../models/profile.dart';
import '../services/local_cache.dart';
import 'providers.dart';
import 'settings_controller.dart';

/// What went wrong, mapped to a localized message in the UI (see ui/errors.dart).
enum ErrorKind {
  loadData,
  saveEntry,
  deleteEntry,
  saveGoal,
  saveWater,
  notSignedIn,
  saveProfile,
  resetData,
  deleteAccount,
  network,
  googleNotConfigured,
  googleFailed,
  generic,

  /// [AppError.message] carries a server message (e.g. "Invalid login credentials").
  raw,
}

class AppError {
  AppError(this.kind, [this.message]) : seq = _nextSeq++;
  static int _nextSeq = 0;

  final ErrorKind kind;
  final String? message;

  /// Distinguishes two identical errors so the toast shows both.
  final int seq;
}

const _unset = Object();

@immutable
class AppState {
  const AppState({
    required this.session,
    required this.recoveryMode,
    required this.entries,
    required this.goal,
    required this.hydration,
    required this.dataLoading,
    required this.loadFailed,
    required this.profile,
    required this.hasOnboarded,
    required this.currentDate,
    required this.error,
  });

  factory AppState.initial(Session? session) => AppState(
    session: session,
    recoveryMode: false,
    entries: const [],
    goal: Goal.defaults,
    hydration: const {},
    dataLoading: false,
    loadFailed: false,
    profile: null,
    hasOnboarded: null,
    currentDate: todayStr(),
    error: null,
  );

  final Session? session;
  final bool recoveryMode; // arrived via a password-reset link
  final List<LogEntry> entries; // newest first
  final Goal goal;
  final Map<String, double> hydration; // YYYY-MM-DD -> ml
  final bool dataLoading;
  final bool loadFailed; // first load failed with nothing cached to show
  final Profile? profile;
  final bool? hasOnboarded; // null = not yet determined
  final String currentDate;
  final AppError? error; // transient, user-facing (toast)

  User? get user => session?.user;

  AppState copyWith({
    Object? session = _unset,
    bool? recoveryMode,
    List<LogEntry>? entries,
    Goal? goal,
    Map<String, double>? hydration,
    bool? dataLoading,
    bool? loadFailed,
    Object? profile = _unset,
    Object? hasOnboarded = _unset,
    String? currentDate,
    Object? error = _unset,
  }) => AppState(
    session: identical(session, _unset) ? this.session : session as Session?,
    recoveryMode: recoveryMode ?? this.recoveryMode,
    entries: entries ?? this.entries,
    goal: goal ?? this.goal,
    hydration: hydration ?? this.hydration,
    dataLoading: dataLoading ?? this.dataLoading,
    loadFailed: loadFailed ?? this.loadFailed,
    profile: identical(profile, _unset) ? this.profile : profile as Profile?,
    hasOnboarded: identical(hasOnboarded, _unset) ? this.hasOnboarded : hasOnboarded as bool?,
    currentDate: currentDate ?? this.currentDate,
    error: identical(error, _unset) ? this.error : error as AppError?,
  );

  /// Signed-out / account-switch reset: keeps only the UI date.
  AppState cleared() => AppState.initial(null).copyWith(currentDate: currentDate);
}

/// All auth + data logic (port of the web app's Zustand store). The app talks
/// to Supabase directly (RLS protects every row). Writes are optimistic with
/// rollback; the last synced data is cached on disk for offline reading.
class AppController extends Notifier<AppState> {
  SupabaseClient get _sb => ref.read(supabaseProvider);
  LocalCache get _cache => ref.read(localCacheProvider);

  StreamSubscription<AuthState>? _authSub;
  Timer? _cacheTimer;
  Future<void> _waterChain = Future.value();
  bool _googleReady = false;

  @override
  AppState build() {
    final auth = _sb.auth;
    _authSub = auth.onAuthStateChange.listen(_onAuthChange, onError: (Object e) => debugPrint('Auth stream error: $e'));
    ref.onDispose(() {
      _authSub?.cancel();
      _cacheTimer?.cancel();
    });
    final session = auth.currentSession;
    if (session != null) Future.microtask(loadData);
    return AppState.initial(session);
  }

  void _onAuthChange(AuthState data) {
    final prevUserId = state.user?.id;
    final session = data.session;
    var next = state.copyWith(session: session);
    // Arrived via a password-reset link: show the update-password screen.
    if (data.event == AuthChangeEvent.passwordRecovery) next = next.copyWith(recoveryMode: true);
    if (session == null) {
      next = next.cleared();
    } else if (session.user.id != prevUserId && prevUserId != null) {
      next = next.cleared().copyWith(session: session); // switched accounts
    }
    state = next;
    // Only (re)load when the user actually changes, not on token refresh.
    if (session != null && session.user.id != prevUserId) unawaited(loadData());
  }

  // ---------- Auth ----------

  Future<AppError?> signIn(String email, String password) =>
      _guardAuth(() => _sb.auth.signInWithPassword(email: email, password: password));

  /// Returns (error, needsConfirmation).
  Future<(AppError?, bool)> signUp(String email, String password) async {
    AuthResponse? res;
    final err = await _guardAuth(() async {
      res = await _sb.auth.signUp(email: email, password: password, emailRedirectTo: AppConfig.authRedirectUrl);
    });
    return (err, err == null && res?.session == null);
  }

  Future<AppError?> resetPassword(String email) =>
      _guardAuth(() => _sb.auth.resetPasswordForEmail(email, redirectTo: AppConfig.authRedirectUrl));

  Future<AppError?> updatePassword(String password) async {
    final err = await _guardAuth(() => _sb.auth.updateUser(UserAttributes(password: password)));
    if (err == null) state = state.copyWith(recoveryMode: false);
    return err;
  }

  /// Native Google sign-in (Credential Manager) → Supabase ID-token exchange.
  /// Returns null on success or when the user cancels the picker.
  Future<AppError?> signInWithGoogle() async {
    if (AppConfig.googleWebClientId.isEmpty) return AppError(ErrorKind.googleNotConfigured);
    try {
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        await google.initialize(serverClientId: AppConfig.googleWebClientId);
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return AppError(ErrorKind.googleFailed);
      await _sb.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      debugPrint('Google sign-in failed: ${e.code} ${e.description}');
      return AppError(ErrorKind.googleFailed, e.description);
    } on AuthException catch (e) {
      return AppError(ErrorKind.raw, e.message);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return AppError(ErrorKind.googleFailed);
    }
  }

  Future<void> signOut() async {
    final uid = state.user?.id;
    if (_googleReady) unawaited(GoogleSignIn.instance.signOut().catchError((_) {}));
    try {
      await _sb.auth.signOut();
    } catch (e) {
      debugPrint('Sign-out network error (local session already removed): $e');
    }
    if (uid != null) await _cache.clear(uid);
    state = state.cleared();
  }

  /// Permanently deletes the account via the `delete_own_account` RPC (security
  /// definer, deletes only auth.uid()); rows cascade-delete.
  Future<AppError?> deleteAccount() async {
    if (state.user == null) return AppError(ErrorKind.notSignedIn);
    try {
      await _sb.rpc('delete_own_account');
    } on PostgrestException catch (e) {
      debugPrint('Account deletion failed: ${e.message}');
      return AppError(ErrorKind.deleteAccount);
    } catch (e) {
      return AppError(ErrorKind.network);
    }
    await signOut();
    return null;
  }

  Future<AppError?> _guardAuth(Future<void> Function() run) async {
    try {
      await run();
      return null;
    } on AuthException catch (e) {
      return AppError(ErrorKind.raw, e.message);
    } catch (e) {
      debugPrint('Auth request failed: $e');
      return AppError(ErrorKind.network);
    }
  }

  // ---------- Data ----------

  Future<void> loadData() async {
    final uid = state.user?.id;
    if (uid == null) return;

    // 1) Show the cached snapshot right away (works offline).
    if (state.profile == null && state.entries.isEmpty) {
      final snap = await _cache.read(uid);
      if (snap != null && state.user?.id == uid) {
        state = state.copyWith(
          entries: snap.entries,
          goal: snap.goal,
          hydration: snap.hydration,
          profile: snap.profile,
          hasOnboarded: snap.profile?.hasOnboarded == true ? true : state.hasOnboarded,
        );
      }
    }

    // 2) Refresh from Supabase.
    state = state.copyWith(dataLoading: true, loadFailed: false);
    try {
      final results = await Future.wait<Object?>([
        _fetchAllEntries(),
        _sb.from('goals').select().maybeSingle(),
        _sb.from('hydration').select('date, consumed_ml'),
        _sb.from('profiles').select().maybeSingle(),
      ]);
      if (state.user?.id != uid) return; // signed out / switched meanwhile

      final entries = results[0] as List<LogEntry>;
      final goalRow = results[1] as Map<String, dynamic>?;
      final hydrationRows = results[2] as List<Map<String, dynamic>>;
      final profileRow = results[3] as Map<String, dynamic>?;
      final profile = profileRow == null ? null : Profile.fromRow(profileRow);

      // A logged-out visitor may have completed the promo quiz before signing
      // up — apply those stashed answers now (for not-yet-onboarded users).
      final prefs = ref.read(sharedPrefsProvider);
      final pending = profile?.hasOnboarded == true ? null : readPendingOnboarding(prefs);

      state = state.copyWith(
        entries: entries,
        goal: goalRow == null ? Goal.defaults : Goal.fromRow(goalRow),
        hydration: {for (final r in hydrationRows) '${r['date']}': (r['consumed_ml'] as num?)?.toDouble() ?? 0},
        profile: profile,
        // Keep the splash up (null) while applying pending answers.
        hasOnboarded: pending != null ? null : (profile?.hasOnboarded ?? false),
        dataLoading: false,
      );
      _scheduleCacheSave();

      // Apply the user's saved language (syncs across devices).
      final lang = profile?.language;
      if (lang != null) ref.read(settingsProvider.notifier).setLanguage(lang);

      if (pending != null) {
        await clearPendingOnboarding(prefs);
        final err = await completeOnboarding(pending);
        if (err != null) state = state.copyWith(hasOnboarded: false);
      }
    } catch (e) {
      debugPrint('Failed to load data: $e');
      if (state.user?.id != uid) return;
      state = state.copyWith(
        dataLoading: false,
        loadFailed: state.hasOnboarded == null, // nothing cached to fall back on
        error: AppError(ErrorKind.loadData),
      );
    }
  }

  /// All entries, newest first. PostgREST caps a response at 1000 rows, so page.
  Future<List<LogEntry>> _fetchAllEntries() async {
    const page = 1000;
    final out = <LogEntry>[];
    for (var from = 0; ; from += page) {
      final rows = await _sb
          .from('entries')
          .select()
          .order('created_at', ascending: false)
          .order('id')
          .range(from, from + page - 1);
      out.addAll(rows.map(LogEntry.fromRow));
      if (rows.length < page) return out;
    }
  }

  Future<AppError?> completeOnboarding(OnboardingData data) async {
    final user = state.user;
    if (user == null) return AppError(ErrorKind.notSignedIn);

    final goal = computeGoal(data);
    final prevGoal = state.goal;
    state = state.copyWith(goal: goal); // optimistic
    final now = DateTime.now().toUtc().toIso8601String();

    try {
      await _sb.from('profiles').upsert({
        'user_id': user.id,
        'has_onboarded': true,
        ...data.toRow(),
        'updated_at': now,
      });
    } catch (e) {
      debugPrint('Failed to save profile: $e');
      state = state.copyWith(goal: prevGoal);
      return AppError(ErrorKind.saveProfile);
    }

    // Persist the computed goal (best-effort; the dashboard already has it).
    try {
      await _sb.from('goals').upsert({'user_id': user.id, ...goal.toRow(), 'updated_at': now});
    } catch (e) {
      debugPrint('Failed to save computed goal: $e');
    }

    // Language as a separate best-effort write (older schemas lack the column).
    final lang = ref.read(settingsProvider).language;
    try {
      await _sb.from('profiles').update({'language': lang}).eq('user_id', user.id);
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }

    state = state.copyWith(profile: Profile.from(data, hasOnboarded: true, language: lang), hasOnboarded: true);
    _scheduleCacheSave();
    return null;
  }

  /// Switch UI language now and, when signed in, persist it to the profile so
  /// it follows the user across devices (best-effort).
  Future<void> updateLanguage(String code) async {
    ref.read(settingsProvider.notifier).setLanguage(code);
    final user = state.user;
    if (user == null) return;
    final profile = state.profile;
    if (profile != null) state = state.copyWith(profile: profile.withLanguage(code));
    try {
      await _sb
          .from('profiles')
          .update({'language': code, 'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
  }

  /// Deletes all logged meals/exercises + hydration (keeps account, profile, goal).
  Future<AppError?> resetData() async {
    final user = state.user;
    if (user == null) return AppError(ErrorKind.notSignedIn);
    final prevEntries = state.entries;
    final prevHydration = state.hydration;
    state = state.copyWith(entries: const [], hydration: const {}); // optimistic
    try {
      await Future.wait([
        _sb.from('entries').delete().eq('user_id', user.id),
        _sb.from('hydration').delete().eq('user_id', user.id),
      ]);
      _scheduleCacheSave();
      return null;
    } catch (e) {
      debugPrint('Failed to reset data: $e');
      state = state.copyWith(entries: prevEntries, hydration: prevHydration); // roll back
      return AppError(ErrorKind.resetData);
    }
  }

  Future<bool> addEntry(NewEntry entry) async {
    final user = state.user;
    if (user == null) return false;
    try {
      final row = await _sb.from('entries').insert(entry.toInsert(user.id)).select().single();
      state = state.copyWith(entries: [LogEntry.fromRow(row), ...state.entries]);
      _scheduleCacheSave();
      return true;
    } catch (e) {
      debugPrint('Failed to add entry: $e');
      _setError(ErrorKind.saveEntry);
      return false;
    }
  }

  Future<void> removeEntry(String id) async {
    final prev = state.entries;
    state = state.copyWith(entries: prev.where((e) => e.id != id).toList()); // optimistic
    try {
      await _sb.from('entries').delete().eq('id', id);
      _scheduleCacheSave();
    } catch (e) {
      debugPrint('Failed to remove entry: $e');
      state = state.copyWith(entries: prev, error: AppError(ErrorKind.deleteEntry));
    }
  }

  Future<void> updateGoal(Goal goal) async {
    final user = state.user;
    if (user == null) return;
    final prev = state.goal;
    state = state.copyWith(goal: goal); // optimistic
    try {
      await _sb.from('goals').upsert({
        'user_id': user.id,
        ...goal.toRow(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      _scheduleCacheSave();
    } catch (e) {
      debugPrint('Failed to update goal: $e');
      state = state.copyWith(goal: prev, error: AppError(ErrorKind.saveGoal));
    }
  }

  Future<void> addQuickCalories(double calories, EntryType type) {
    final meal = type == EntryType.meal;
    return addEntry(
      NewEntry(
        date: state.currentDate,
        type: type,
        name: meal ? 'Quick Snack' : 'Quick Workout',
        calories: calories,
        protein: meal ? (calories * 0.05).roundToDouble() : 0, // estimate small macros
        carbs: meal ? (calories * 0.12).roundToDouble() : 0,
        fat: meal ? (calories * 0.02).roundToDouble() : 0,
        quantity: meal ? 100 : 30, // generic unit weight/time
      ),
    );
  }

  /// Optimistic water change. Writes are chained so rapid taps reach the
  /// server in order and the last write always carries the latest total.
  Future<void> adjustWater(double deltaMl) {
    final user = state.user;
    if (user == null) return Future.value();
    final date = state.currentDate;
    final current = state.hydration[date] ?? 0;
    state = state.copyWith(hydration: {...state.hydration, date: math.max(0, current + deltaMl)});

    return _waterChain = _waterChain.then((_) async {
      final amount = state.hydration[date] ?? 0;
      try {
        await _sb.from('hydration').upsert({
          'user_id': user.id,
          'date': date,
          'consumed_ml': amount,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        _scheduleCacheSave();
      } catch (e) {
        debugPrint('Failed to update hydration: $e');
        final now = state.hydration[date] ?? 0;
        state = state.copyWith(
          hydration: {...state.hydration, date: math.max(0, now - deltaMl)}, // undo this tap
          error: AppError(ErrorKind.saveWater),
        );
      }
    });
  }

  // ---------- UI ----------

  void setCurrentDate(String date) => state = state.copyWith(currentDate: date);

  void clearError() => state = state.copyWith(error: null);

  void _setError(ErrorKind kind) => state = state.copyWith(error: AppError(kind));

  // ---------- Local cache ----------

  void _scheduleCacheSave() {
    _cacheTimer?.cancel();
    _cacheTimer = Timer(const Duration(milliseconds: 400), () {
      final uid = state.user?.id;
      if (uid == null || state.hasOnboarded == null) return;
      _cache.write(
        uid,
        DataSnapshot(entries: state.entries, goal: state.goal, hydration: state.hydration, profile: state.profile),
      );
    });
  }
}

final appProvider = NotifierProvider<AppController, AppState>(AppController.new);
