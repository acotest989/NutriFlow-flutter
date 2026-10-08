import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'l10n/app_localizations.dart';
import 'state/app_controller.dart';
import 'state/providers.dart';
import 'state/settings_controller.dart';
import 'ui/errors.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/home_shell.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/update_password_screen.dart';
import 'ui/theme.dart';
import 'ui/widgets.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class NutriFlowApp extends ConsumerWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = buildTheme(settings.theme);
    final c = theme.extension<NfColors>()!;

    return MaterialApp(
      title: 'NutriFlow',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: theme,
      locale: flutterLocale(settings.language),
      supportedLocales: [for (final l in appLanguages) flutterLocale(l.code)],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: (c.isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light).copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemStatusBarContrastEnforced: false,
        ),
        child: _ErrorToaster(child: _OfflineBanner(child: child!)),
      ),
      home: const _AuthGate(),
    );
  }
}

/// Picks the screen for the current auth / onboarding state (App.tsx gating).
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final Widget screen;
    if (s.recoveryMode) {
      screen = const UpdatePasswordScreen(key: ValueKey('recovery'));
    } else if (s.user == null) {
      screen = const AuthScreen(key: ValueKey('auth'));
    } else if (s.hasOnboarded == null) {
      screen = s.loadFailed
          ? const _LoadFailedView(key: ValueKey('failed'))
          : const SplashView(key: ValueKey('splash'));
    } else if (s.hasOnboarded == false) {
      screen = const OnboardingScreen(key: ValueKey('onboarding'));
    } else {
      screen = const HomeShell(key: ValueKey('home'));
    }
    return AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: screen);
  }
}

/// Branded loading screen (matches the native launch splash).
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.isLight ? c.bg : const Color(0xFF0B0E14),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 72, radius: 24),
            const SizedBox(height: 20),
            const BrandWordmark(size: 20),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spinner(size: 14),
                const SizedBox(width: 8),
                Text(t.appLoadingWorkspace, style: ts(12, color: c.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// First load failed and nothing is cached yet (e.g. first launch offline).
class _LoadFailedView extends ConsumerWidget {
  const _LoadFailedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTile(icon: LucideIcons.wifiOff, color: c.amberText, size: 56),
                const SizedBox(height: 16),
                Text(
                  t.appLoadFailedTitle,
                  style: ts(18, weight: w800, color: c.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.errLoadData,
                  style: ts(13, color: c.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                NfButton(
                  label: t.appRetry,
                  icon: LucideIcons.rotateCcw,
                  onPressed: () => ref.read(appProvider.notifier).loadData(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.read(appProvider.notifier).signOut(),
                  child: Text(t.headerSignOut, style: ts(12, color: c.textMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows [AppState.error] as a dismissible toast (auto-hides after 5 s).
class _ErrorToaster extends ConsumerWidget {
  const _ErrorToaster({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appProvider.select((s) => s.error), (prev, next) {
      if (next == null || identical(prev, next)) return;
      final messenger = _messengerKey.currentState;
      final ctx = _messengerKey.currentContext;
      if (messenger == null || ctx == null) return;
      final c = Theme.of(ctx).extension<NfColors>()!;
      final text = appErrorText(AppLocalizations.of(ctx), next);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            backgroundColor: c.card,
            elevation: 6,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: c.isLight ? c.border : NfColors.rose.withValues(alpha: 0.3),
                width: c.isLight ? 2 : 1,
              ),
            ),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.triangleAlert, size: 16, color: c.roseText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text, style: ts(12, color: c.textBody, height: 1.5)),
                ),
              ],
            ),
            showCloseIcon: true,
            closeIconColor: c.textMuted,
          ),
        );
      ref.read(appProvider.notifier).clearError();
    });
    return child;
  }
}

/// Slim amber banner while the device is offline (data still shows from cache).
class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider).value ?? true;
    if (online) return child;
    final t = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: NfColors.amber,
          padding: EdgeInsets.fromLTRB(12, top + 4, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff, size: 12, color: Color(0xFF0B0E14)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  t.commonOffline.toUpperCase(),
                  style: ts(10, weight: w700, mono: true, color: const Color(0xFF0B0E14), letterSpacing: 0.8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
        ),
      ],
    );
  }
}
