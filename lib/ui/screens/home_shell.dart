import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../../state/settings_controller.dart';
import '../dialogs.dart';
import '../theme.dart';
import '../widgets.dart';
import 'onboarding_screen.dart';
import 'tabs/coach_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/exercise_tab.dart';
import 'tabs/meals_tab.dart';
import 'tabs/scan_tab.dart';
import 'tabs/trends_tab.dart';

enum HomeTab { dashboard, meals, exercises, coach, charts, scanner }

/// Signed-in app: header, the six section tabs, footer links, bottom nav.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _tab = HomeTab.dashboard;
  // Tabs are built on first visit, then kept alive (results/forms survive tab switches).
  final _visited = <HomeTab>{HomeTab.dashboard};

  void _select(HomeTab tab) {
    if (tab == _tab) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() {
      _tab = tab;
      _visited.add(tab);
    });
  }

  Widget _tabBody(HomeTab tab) => switch (tab) {
    HomeTab.dashboard => const DashboardTab(),
    HomeTab.meals => const MealsTab(),
    HomeTab.exercises => const ExerciseTab(),
    HomeTab.coach => const CoachTab(),
    HomeTab.charts => const TrendsTab(),
    HomeTab.scanner => ScanTab(active: _tab == HomeTab.scanner),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return PopScope(
      // Back from another tab returns to the dashboard before leaving the app.
      canPop: _tab == HomeTab.dashboard,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(HomeTab.dashboard);
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: IndexedStack(
                index: _tab.index,
                children: [
                  for (final tab in HomeTab.values)
                    _visited.contains(tab)
                        ? _TabScroll(key: PageStorageKey(tab), child: _tabBody(tab))
                        : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomNav(selected: _tab, onSelect: _select),
      ),
    );
  }
}

/// Scrollable tab page with the shared footer at the end.
class _TabScroll extends StatelessWidget {
  const _TabScroll({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    child: Column(children: [child, const SizedBox(height: 24), const _Footer()]),
  );
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final syncing = ref.watch(appProvider.select((s) => s.dataLoading));
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(
          bottom: BorderSide(color: c.cardBorder, width: c.cardBorderWidth),
        ),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: EdgeInsets.only(top: top),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            child: Row(
              children: [
                const BrandMark(size: 32, radius: 8),
                const SizedBox(width: 8),
                const BrandWordmark(size: 14),
                const Spacer(),
                const LanguageSwitcher(),
                const SizedBox(width: 8),
                NfIconButton(
                  icon: theme == AppTheme.dark ? LucideIcons.sun : LucideIcons.moon,
                  color: theme == AppTheme.dark ? const Color(0xFFFBBF24) : c.accent,
                  tooltip: theme == AppTheme.dark ? t.headerThemeToLight : t.headerThemeToDark,
                  onPressed: () => ref.read(settingsProvider.notifier).toggleTheme(),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: syncing ? t.appSyncing : t.headerSyncOn,
                  child: _PulseDot(color: syncing ? NfColors.indigoLight : const Color(0xFF10B981)),
                ),
                const SizedBox(width: 10),
                NfIconButton(
                  icon: LucideIcons.logOut,
                  size: 16,
                  tooltip: t.headerSignOut,
                  onPressed: () => ref.read(appProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
          // Thin sync indicator while (re)loading the user's data.
          SizedBox(
            height: 2,
            child: syncing ? const LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent) : null,
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: 0.4, end: 1.0).animate(_ctl),
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    ),
  );
}

/// Header language picker (EN / SR / HR / BS).
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final code = ref.watch(settingsProvider.select((s) => s.language));
    final current = appLanguages.firstWhere((l) => l.code == code, orElse: () => appLanguages.first);
    return PopupMenuButton<String>(
      tooltip: t.langLabel,
      position: PopupMenuPosition.under,
      onSelected: (code) => ref.read(appProvider.notifier).updateLanguage(code),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          height: 28,
          child: Text(
            t.langLabel.toUpperCase(),
            style: ts(9, weight: w700, mono: true, color: c.textMuted),
          ),
        ),
        for (final l in appLanguages)
          PopupMenuItem<String>(
            value: l.code,
            height: 40,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    l.short,
                    style: ts(10, weight: w700, mono: true, color: c.accent),
                  ),
                ),
                Expanded(
                  child: Text(
                    l.label,
                    style: ts(12, weight: w600, color: l.code == code ? c.text : c.textSecondary),
                  ),
                ),
                if (l.code == code) Icon(LucideIcons.check, size: 14, color: c.emeraldText),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: c.subtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.borderStrong, width: c.isLight ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.languages, size: 16, color: c.accent),
            const SizedBox(width: 6),
            Text(
              current.short,
              style: ts(11, weight: w700, mono: true, color: c.textBody),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onSelect});
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final items = [
      (HomeTab.dashboard, LucideIcons.layoutDashboard, t.navDashboard),
      (HomeTab.meals, LucideIcons.apple, t.navMeals),
      (HomeTab.exercises, LucideIcons.dumbbell, t.navActive),
      (HomeTab.coach, LucideIcons.sparkles, t.navCoach),
      (HomeTab.charts, LucideIcons.trendingUp, t.navTrends),
      (HomeTab.scanner, LucideIcons.scan, t.navScan),
    ];
    return Container(
      decoration: BoxDecoration(
        color: c.navBar,
        border: Border(
          top: BorderSide(color: c.cardBorder, width: c.cardBorderWidth),
        ),
        boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 10, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          for (final (tab, icon, label) in items)
            Expanded(
              child: InkWell(
                onTap: () => onSelect(tab),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: AnimatedScale(
                    scale: tab == selected ? 1.05 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 20, color: tab == selected ? c.accent : c.textSecondary),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(
                            9.5,
                            weight: tab == selected ? w700 : w600,
                            color: tab == selected ? c.accent : c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Footer links + brand line (the web app's footer).
class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);

    Widget link(String label, VoidCallback onTap, {Color? hover, IconData? icon}) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 13, color: hover ?? c.textSecondary), const SizedBox(width: 4)],
            Text(label, style: ts(12, color: hover ?? c.textSecondary)),
          ],
        ),
      ),
    );
    final dot = Text('·', style: ts(12, color: c.isLight ? c.textMuted : const Color(0xFF334155)));

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            link(t.footerPrivacy, () => _open(Uri.parse(AppConfig.privacyUrl))),
            dot,
            link(t.footerEditProfile, () {
              final profile = ref.read(appProvider).profile;
              Navigator.of(
                context,
              ).push(MaterialPageRoute<bool>(builder: (_) => OnboardingScreen(initial: profile, editing: true)));
            }),
            dot,
            link(t.footerResetData, () => showResetDataDialog(context)),
            dot,
            link(t.footerDeleteAccount, () => showDeleteAccountDialog(context)),
            dot,
            link(t.footerContact, () => _open(Uri(scheme: 'mailto', path: AppConfig.contactEmail))),
            dot,
            link(t.footerRate, () => _open(Uri.parse(AppConfig.playStoreUrl)), hover: c.accent, icon: LucideIcons.star),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          t.footerTagline,
          style: ts(11, color: c.textMuted),
          textAlign: TextAlign.center,
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) => snap.hasData
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(t.footerVersion(snap.data!.version), style: ts(10, color: c.textFaint, mono: true)),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  static Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
