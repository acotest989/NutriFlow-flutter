import 'package:flutter/material.dart';

import '../state/settings_controller.dart';

const fontSans = 'Inter';
const fontMono = 'JetBrainsMono';

/// Semantic colors shared by every screen. Mirrors the web app's two themes:
/// "Deep Midnight" (dark) and "High Contrast Light" (neo-brutalist light with
/// hard borders + offset shadows).
@immutable
class NfColors extends ThemeExtension<NfColors> {
  const NfColors({
    required this.isLight,
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.cardBorderWidth,
    required this.inset,
    required this.insetBorder,
    required this.subtle,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textBody,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.primary,
    required this.onPrimary,
    required this.greenText,
    required this.skyText,
    required this.roseText,
    required this.amberText,
    required this.emeraldText,
    required this.navBar,
    required this.chartGrid,
  });

  final bool isLight;
  final Color bg; // page background
  final Color card; // card surface
  final Color cardBorder;
  final double cardBorderWidth;
  final Color inset; // inputs / rows inside cards
  final Color insetBorder;
  final Color subtle; // faint fill (bg-white/5)
  final Color border; // hairline divider (border-white/5)
  final Color borderStrong; // input outline (border-white/10)
  final Color text; // headings (text-white)
  final Color textBody; // #E2E8F0
  final Color textSecondary; // #94A3B8
  final Color textMuted; // #64748B
  final Color textFaint; // #475569
  final Color accent; // indigo text/icons (#818CF8)
  final Color primary; // indigo buttons (#6366F1)
  final Color onPrimary;
  final Color greenText;
  final Color skyText;
  final Color roseText;
  final Color amberText;
  final Color emeraldText;
  final Color navBar;
  final Color chartGrid;

  // Fills that look the same in both themes (bars, dots, rings).
  static const indigo = Color(0xFF6366F1);
  static const indigoLight = Color(0xFF818CF8);
  static const purple = Color(0xFFA855F7);
  static const green = Color(0xFF4ADE80);
  static const greenDark = Color(0xFF22C55E);
  static const sky = Color(0xFF38BDF8);
  static const skyDark = Color(0xFF0284C7);
  static const orange = Color(0xFFFB923C);
  static const yellow = Color(0xFFFACC15);
  static const rose = Color(0xFFF43F5E);
  static const roseSoft = Color(0xFFFB7185);
  static const emerald = Color(0xFF10B981);
  static const emeraldSoft = Color(0xFF34D399);
  static const amber = Color(0xFFF59E0B);
  static const amberDark = Color(0xFFD97706);
  static const slate = Color(0xFF64748B);

  static const dark = NfColors(
    isLight: false,
    bg: Color(0xFF0B0E14),
    card: Color(0xFF141923),
    cardBorder: Color(0x0DFFFFFF),
    cardBorderWidth: 1,
    inset: Color(0xFF0B0E14),
    insetBorder: Color(0x0DFFFFFF),
    subtle: Color(0x0DFFFFFF),
    border: Color(0x0DFFFFFF),
    borderStrong: Color(0x1AFFFFFF),
    text: Color(0xFFFFFFFF),
    textBody: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    textFaint: Color(0xFF475569),
    accent: Color(0xFF818CF8),
    primary: Color(0xFF6366F1),
    onPrimary: Colors.white,
    greenText: Color(0xFF4ADE80),
    skyText: Color(0xFF38BDF8),
    roseText: Color(0xFFFB7185),
    amberText: Color(0xFFFCD34D),
    emeraldText: Color(0xFF34D399),
    navBar: Color(0xF2141923),
    chartGrid: Color(0xFF1E293B),
  );

  static const light = NfColors(
    isLight: true,
    bg: Color(0xFFF8FAFC),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFF0F172A),
    cardBorderWidth: 2,
    inset: Color(0xFFF1F5F9),
    insetBorder: Color(0xFF475569),
    subtle: Color(0xFFE2E8F0),
    border: Color(0xFF0F172A),
    borderStrong: Color(0xFF0F172A),
    text: Color(0xFF0F172A),
    textBody: Color(0xFF1E293B),
    textSecondary: Color(0xFF1E293B),
    textMuted: Color(0xFF334155),
    textFaint: Color(0xFF475569),
    accent: Color(0xFF312E81),
    primary: Color(0xFF1E1B4B),
    onPrimary: Colors.white,
    greenText: Color(0xFF064E3B),
    skyText: Color(0xFF075985),
    roseText: Color(0xFF881337),
    amberText: Color(0xFF78350F),
    emeraldText: Color(0xFF064E3B),
    navBar: Color(0xFFFFFFFF),
    chartGrid: Color(0xFF94A3B8),
  );

  /// Hard offset shadow of the light theme; soft drop shadow in dark.
  List<BoxShadow> get cardShadow => isLight
      ? const [BoxShadow(color: Color(0xFF0F172A), offset: Offset(4, 4))]
      : const [BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))];

  @override
  NfColors copyWith() => this;

  @override
  NfColors lerp(ThemeExtension<NfColors>? other, double t) => t < 0.5 ? this : (other as NfColors? ?? this);
}

extension NfThemeX on BuildContext {
  NfColors get nf => Theme.of(this).extension<NfColors>()!;
}

ThemeData buildTheme(AppTheme mode) {
  final c = mode == AppTheme.light ? NfColors.light : NfColors.dark;
  final brightness = c.isLight ? Brightness.light : Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: NfColors.indigo,
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    surface: c.card,
    onSurface: c.text,
    error: NfColors.rose,
  );
  final base = ThemeData(brightness: brightness, colorScheme: scheme, useMaterial3: true, fontFamily: fontSans);
  return base.copyWith(
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
    textTheme: base.textTheme.apply(bodyColor: c.text, displayColor: c.text, fontFamily: fontSans),
    dividerColor: c.border,
    splashFactory: InkRipple.splashFactory,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: NfColors.indigoLight,
      selectionColor: NfColors.indigo.withValues(alpha: 0.4),
      selectionHandleColor: NfColors.indigo,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: NfColors.indigo,
      thumbColor: NfColors.indigo,
      inactiveTrackColor: c.subtle,
      overlayColor: NfColors.indigo.withValues(alpha: 0.15),
      trackHeight: 4,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: NfColors.indigoLight),
    dialogTheme: DialogThemeData(backgroundColor: c.card, surfaceTintColor: Colors.transparent),
    popupMenuTheme: PopupMenuThemeData(
      color: c.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.borderStrong, width: c.cardBorderWidth),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.card,
      contentTextStyle: TextStyle(color: c.textBody),
    ),
  );
}
