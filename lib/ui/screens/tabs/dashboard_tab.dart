import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/date_utils.dart';
import '../../../core/day_totals.dart';
import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/goal.dart';
import '../../../models/log_entry.dart';
import '../../../state/app_controller.dart';
import '../../../state/settings_controller.dart';
import '../../theme.dart';
import '../../widgets.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) =>
      Column(children: spaced(const [_DateNavigator(), _CalorieCard(), _MacrosCard(), WaterTracker()], 16));
}

class _DateNavigator extends ConsumerWidget {
  const _DateNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final date = ref.watch(appProvider.select((s) => s.currentDate));
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final app = ref.read(appProvider.notifier);

    final today = todayStr();
    final label = date == today
        ? t.dashboardToday
        : date == addDays(today, -1)
        ? t.dashboardYesterday
        : _capitalize(DateFormat.MMMMEEEEd(intlLocale(lang)).format(parseDateStr(date)));

    Widget arrow(IconData icon, int delta) => IconButton(
      onPressed: () => app.setCurrentDate(addDays(date, delta)),
      icon: Icon(icon, size: 20, color: c.textSecondary),
    );

    return NfCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      radius: 16,
      child: Row(
        children: [
          arrow(LucideIcons.chevronLeft, -1),
          Expanded(
            child: GestureDetector(
              onTap: date == today ? null : () => app.setCurrentDate(today),
              child: Column(
                children: [
                  Text(
                    label,
                    style: ts(16, weight: w600, color: c.text),
                    textAlign: TextAlign.center,
                  ),
                  Text(date, style: ts(10, mono: true, color: c.textMuted)),
                ],
              ),
            ),
          ),
          arrow(LucideIcons.chevronRight, 1),
        ],
      ),
    );
  }
}

class _CalorieCard extends ConsumerStatefulWidget {
  const _CalorieCard();

  @override
  ConsumerState<_CalorieCard> createState() => _CalorieCardState();
}

class _CalorieCardState extends ConsumerState<_CalorieCard> {
  var _editing = false;
  final _cal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();

  @override
  void dispose() {
    for (final ctl in [_cal, _protein, _carbs, _fat]) {
      ctl.dispose();
    }
    super.dispose();
  }

  void _toggleEdit(Goal goal) {
    _cal.text = fmtNum(goal.calories, maxDecimals: 0);
    _protein.text = fmtNum(goal.protein, maxDecimals: 0);
    _carbs.text = fmtNum(goal.carbs, maxDecimals: 0);
    _fat.text = fmtNum(goal.fat, maxDecimals: 0);
    setState(() => _editing = !_editing);
  }

  void _save() {
    double v(TextEditingController ctl) => math.max(1, (parseNum(ctl.text) ?? 0).roundToDouble());
    ref
        .read(appProvider.notifier)
        .updateGoal(Goal(calories: v(_cal), protein: v(_protein), carbs: v(_carbs), fat: v(_fat)));
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final s = ref.watch(appProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final totals = DayTotals.of(s.entries, s.currentDate);
    final goal = s.goal;
    final remaining = goal.calories - totals.net;
    final percent = goal.calories > 0 ? (totals.net / goal.calories * 100).clamp(0, 100).toDouble() : 0.0;
    final app = ref.read(appProvider.notifier);

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.target, size: 16, color: c.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.dashboardBalanceTitle,
                  style: ts(14, weight: w700, color: c.accent),
                ),
              ),
              TextButton.icon(
                onPressed: () => _toggleEdit(goal),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(LucideIcons.settings, size: 16, color: c.textMuted),
                label: Text(
                  t.dashboardAdjustGoal,
                  style: ts(11, weight: w600, color: c.textMuted),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 20),
            child: Divider(height: 1, color: c.border),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _editing
                ? _goalForm(t, c)
                : Column(
                    key: const ValueKey('summary'),
                    children: [
                      _CalorieRing(
                        percent: percent,
                        over: remaining < 0,
                        value: NumberFormat.decimalPattern(intlLocale(lang)).format(remaining.abs().round()),
                        caption: remaining >= 0 ? t.dashboardKcalLeft : t.dashboardOverTarget,
                        badge: remaining >= 0
                            ? t.dashboardPercentDone(percent.toStringAsFixed(0))
                            : t.dashboardExceeded,
                      ),
                      const SizedBox(height: 24),
                      _StatRow(
                        icon: LucideIcons.apple,
                        color: NfColors.indigoLight,
                        textColor: c.accent,
                        label: t.dashboardConsumedFood,
                        value: totals.consumed,
                        quickLabel: '200',
                        quickTooltip: t.dashboardQuickAddMeal,
                        onQuick: () => app.addQuickCalories(200, EntryType.meal),
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        icon: LucideIcons.flame,
                        color: NfColors.green,
                        textColor: c.greenText,
                        label: t.dashboardBurnedWorkouts,
                        value: totals.burned,
                        quickLabel: '150',
                        quickTooltip: t.dashboardQuickAddExercise,
                        onQuick: () => app.addQuickCalories(150, EntryType.exercise),
                      ),
                      const SizedBox(height: 12),
                      _DashedDivider(color: c.border),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _budgetText(c, t.dashboardDailyBudget, goal.calories)),
                          _budgetText(c, t.dashboardNetCalories, totals.net),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _budgetText(NfColors c, String label, double kcal) => Text.rich(
    TextSpan(
      style: ts(12, color: c.textMuted),
      children: [
        TextSpan(text: '$label '),
        TextSpan(
          text: '${fmtNum(kcal, maxDecimals: 0)} kcal',
          style: ts(12, weight: w700, color: c.textSecondary),
        ),
      ],
    ),
  );

  Widget _goalForm(AppLocalizations t, NfColors c) {
    Widget field(String label, TextEditingController ctl) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        NfTextField(
          controller: ctl,
          keyboardType: TextInputType.number,
          inputFormatters: NfTextField.integerFormatters,
          dense: true,
        ),
      ],
    );
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: t.dashboardCustomGoalSettings, icon: LucideIcons.target, size: 14),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: field(t.dashboardCaloriesLabel, _cal)),
            const SizedBox(width: 12),
            Expanded(child: field(t.dashboardProteinLabel, _protein)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: field(t.dashboardCarbsLabel, _carbs)),
            const SizedBox(width: 12),
            Expanded(child: field(t.dashboardFatLabel, _fat)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            NfButton(
              label: t.commonCancel,
              variant: NfButtonVariant.secondary,
              small: true,
              onPressed: () => setState(() => _editing = false),
            ),
            const SizedBox(width: 8),
            NfButton(label: t.dashboardSaveGoals, small: true, onPressed: _save),
          ],
        ),
      ],
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.percent,
    required this.over,
    required this.value,
    required this.caption,
    required this.badge,
  });

  final double percent;
  final bool over;
  final String value;
  final String caption;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final ringColor = over ? NfColors.rose : NfColors.indigoLight;
    return SizedBox.square(
      dimension: 192,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percent / 100),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, v, child) => CustomPaint(
          painter: _RingPainter(
            progress: v,
            color: ringColor,
            track: c.isLight ? const Color(0xFFE2E8F0) : const Color(0x0DFFFFFF),
          ),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: ts(36, weight: w700, color: c.text, letterSpacing: -1, height: 1.1),
              ),
              Text(
                caption.toUpperCase(),
                style: ts(10, weight: w600, color: c.textMuted, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Pill(
                badge,
                color: over ? c.roseText : c.accent,
                background: (over ? NfColors.rose : NfColors.indigo).withValues(alpha: 0.1),
                borderColor: (over ? NfColors.rose : NfColors.indigo).withValues(alpha: 0.1),
                weight: w600,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color, required this.track});
  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 80);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color || old.track != track;
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.color,
    required this.textColor,
    required this.label,
    required this.value,
    required this.quickLabel,
    required this.quickTooltip,
    required this.onQuick,
  });

  final IconData icon;
  final Color color;
  final Color textColor;
  final String label;
  final double value;
  final String quickLabel;
  final String quickTooltip;
  final VoidCallback onQuick;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.isLight ? c.inset : const Color(0x05FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.isLight ? c.insetBorder : c.border),
      ),
      child: Row(
        children: [
          IconTile(icon: icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ts(12, weight: w500, color: c.textSecondary),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: fmtNum(value, maxDecimals: 0),
                        style: ts(20, weight: w700, color: c.text),
                      ),
                      TextSpan(
                        text: ' kcal',
                        style: ts(10, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: quickTooltip,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onQuick,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.subtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.borderStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: textColor),
                      const SizedBox(width: 2),
                      Text(
                        quickLabel,
                        style: ts(11, weight: w600, color: textColor),
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

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final count = (box.maxWidth / 8).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Expanded(
            child: Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 2), color: color),
          ),
        ),
      );
    },
  );
}

class _MacrosCard extends ConsumerWidget {
  const _MacrosCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final s = ref.watch(appProvider);
    final totals = DayTotals.of(s.entries, s.currentDate);
    final remaining = s.goal.calories - totals.net;

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.dashboardMacrosTitle, icon: LucideIcons.utensils),
          const SizedBox(height: 20),
          _MacroBar(label: t.dashboardProtein, color: NfColors.orange, actual: totals.protein, goal: s.goal.protein),
          const SizedBox(height: 20),
          _MacroBar(label: t.dashboardCarbohydrates, color: NfColors.sky, actual: totals.carbs, goal: s.goal.carbs),
          const SizedBox(height: 20),
          _MacroBar(label: t.dashboardFats, color: NfColors.yellow, actual: totals.fat, goal: s.goal.fat),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NfColors.indigo.withValues(alpha: c.isLight ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.isLight ? c.accent : NfColors.indigo.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.circleCheck, size: 20, color: c.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remaining > 0
                            ? t.dashboardStatusLeft(fmtNum(remaining, maxDecimals: 0))
                            : t.dashboardStatusDone,
                        style: ts(12, weight: w600, color: c.accent, height: 1.4),
                      ),
                      const SizedBox(height: 2),
                      Text(t.dashboardMacrosNote, style: ts(10, color: c.textSecondary, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.label, required this.color, required this.actual, required this.goal});
  final String label;
  final Color color;
  final double actual;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final pct = goal > 0 ? (actual / goal * 100).clamp(0, 100).toDouble() : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: ts(12, weight: w600, color: c.textBody),
              ),
            ),
            Text.rich(
              TextSpan(
                style: ts(12, color: c.textSecondary),
                children: [
                  TextSpan(
                    text: '${actual.toStringAsFixed(1)}g',
                    style: ts(12, weight: w700, color: c.text),
                  ),
                  TextSpan(text: ' / ${fmtNum(goal)}g (${pct.toStringAsFixed(0)}%)'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: c.subtle,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: c.border),
          ),
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct / 100),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, _) => FractionallySizedBox(
              widthFactor: v,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hydration card with the animated water cup (+250 / +500 / −250 ml).
class WaterTracker extends ConsumerWidget {
  const WaterTracker({super.key});

  static const _target = 2500.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final consumed = ref.watch(appProvider.select((s) => s.hydration[s.currentDate] ?? 0));
    final percent = math.min(100, (consumed / _target * 100).round());
    final app = ref.read(appProvider.notifier);

    Widget btn(String amount, String label, IconData icon, double delta, {bool reduce = false}) => Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => app.adjustWater(delta),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: c.isLight ? c.inset : const Color(0x05FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.isLight ? c.insetBorder : c.border),
            ),
            child: Column(
              children: [
                Icon(icon, size: 14, color: reduce ? c.textSecondary : c.skyText),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: ts(10, weight: w700, mono: true, color: reduce ? c.textSecondary : c.text),
                ),
                Text(label, style: ts(9, color: c.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );

    return NfCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.droplet, size: 18, color: c.skyText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.waterTitle,
                  style: ts(14, weight: w700, color: c.skyText),
                ),
              ),
              Pill(
                t.waterTarget.toUpperCase(),
                color: c.skyText,
                background: NfColors.sky.withValues(alpha: 0.1),
                mono: true,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: c.border),
          ),
          Row(
            children: [
              _WaterCup(percent: percent / 100),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: fmtNum(consumed, maxDecimals: 0),
                            style: ts(24, weight: w900, mono: true, color: c.text),
                          ),
                          TextSpan(
                            text: ' ml',
                            style: ts(12, weight: w600, color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      percent >= 100 ? t.waterPerfect : t.waterRemaining(fmtNum(_target - consumed, maxDecimals: 0)),
                      style: ts(11, color: c.textSecondary, height: 1.3),
                    ),
                    if (percent >= 100) ...[
                      const SizedBox(height: 6),
                      Pill(
                        t.waterHydrated,
                        icon: LucideIcons.award,
                        color: c.emeraldText,
                        background: NfColors.emerald.withValues(alpha: 0.1),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 16),
          Row(
            children: [
              btn('+250ml', t.waterCup, LucideIcons.plus, 250),
              const SizedBox(width: 8),
              btn('+500ml', t.waterGlass, LucideIcons.plus, 500),
              const SizedBox(width: 8),
              btn('-250ml', t.waterReduce, LucideIcons.trash2, -250, reduce: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterCup extends StatelessWidget {
  const _WaterCup({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Container(
      width: 64,
      height: 112,
      decoration: BoxDecoration(
        color: c.inset,
        border: Border.all(color: c.isLight ? c.border : c.borderStrong, width: 3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(3),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (_, v, _) => FractionallySizedBox(
                  heightFactor: v.clamp(0, 1),
                  widthFactor: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [NfColors.skyDark, NfColors.sky],
                      ),
                    ),
                    alignment: Alignment.topCenter,
                    child: Container(height: 3, color: Colors.white24),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '${(percent * 100).round()}%',
                style: ts(10, weight: w700, mono: true, color: c.isLight ? c.textMuted : Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slavic locales format weekdays in lower case ("srijeda, 8. oktobar").
String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
