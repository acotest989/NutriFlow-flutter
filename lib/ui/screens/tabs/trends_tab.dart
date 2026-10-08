import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/date_utils.dart';
import '../../../core/day_totals.dart';
import '../../../core/format.dart';
import '../../../core/streaks.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/app_controller.dart';
import '../../../state/settings_controller.dart';
import '../../labels.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Streak + badges, 7-day calorie balance chart, today's macro energy share.
class TrendsTab extends ConsumerWidget {
  const TrendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(appProvider.select((s) => s.entries));
    final hydration = ref.watch(appProvider.select((s) => s.hydration));
    final stats = computeStreakStats(entries, hydration);
    return Column(
      children: spaced([
        _StreakHero(stats: stats),
        _Achievements(badges: computeBadges(stats)),
        const _TrendChart(),
        const _EnergyShare(),
      ], 16),
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.stats});
  final StreakStats stats;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final s = stats;
    final title = s.current > 0 ? t.chartsStreakTitle('${s.current}', t.chartsDays(s.current)) : t.chartsStartStreak;
    final body = s.current > 0
        ? (s.todayActive ? t.chartsStreakToday(t.chartsDays(s.longest)) : t.chartsStreakAlive(t.chartsDays(s.longest)))
        : t.chartsStreakStart;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [NfColors.indigo, Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.isLight ? c.cardBorder : c.border, width: c.cardBorderWidth),
        boxShadow: c.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.flame, size: 20, color: s.current > 0 ? const Color(0xFFFCD34D) : Colors.white54),
                Text(
                  '${s.current}',
                  style: ts(20, weight: w900, color: Colors.white, height: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ts(14, weight: w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(body, style: ts(12, color: const Color(0xFFE2E8F0), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.badges});
  final List<Achievement> badges;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final earned = badges.where((b) => b.earned).length;
    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: t.chartsAchievements,
            icon: LucideIcons.award,
            trailing: Pill(
              '$earned / ${badges.length}',
              mono: true,
              size: 11,
              color: c.accent,
              background: NfColors.indigo.withValues(alpha: 0.1),
              borderColor: NfColors.indigo.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 12),
          Text(t.chartsAchievementsExplainer, style: ts(11, color: c.textSecondary, height: 1.5)),
          const SizedBox(height: 16),
          ...spaced([
            for (final b in badges)
              Builder(
                builder: (context) {
                  final (label, desc) = badgeText(t, b.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: b.earned ? NfColors.indigo.withValues(alpha: 0.1) : c.inset,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: b.earned ? NfColors.indigo.withValues(alpha: 0.25) : c.border),
                    ),
                    child: Row(
                      children: [
                        Opacity(
                          opacity: b.earned ? 1 : 0.3,
                          child: Text(b.emoji, style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: ts(12, weight: w700, color: b.earned ? c.text : c.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(desc, style: ts(10, color: b.earned ? c.textSecondary : c.textFaint)),
                            ],
                          ),
                        ),
                        b.earned
                            ? Icon(LucideIcons.check, size: 16, color: c.emeraldText)
                            : Icon(LucideIcons.lock, size: 14, color: c.textFaint),
                      ],
                    ),
                  );
                },
              ),
          ], 8),
        ],
      ),
    );
  }
}

class _DayPoint {
  const _DayPoint(this.label, this.food, this.burn, this.net);
  final String label;
  final double food;
  final double burn;
  final double net;
}

class _TrendChart extends ConsumerWidget {
  const _TrendChart();

  static const _leftReserved = 40.0;
  static const _bottomReserved = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final entries = ref.watch(appProvider.select((s) => s.entries));
    final goal = ref.watch(appProvider.select((s) => s.goal.calories));
    final locale = intlLocale(ref.watch(settingsProvider.select((s) => s.language)));

    // 7 local calendar days ending today (matches how entries are dated).
    final today = todayStr();
    final days = [
      for (var i = 6; i >= 0; i--)
        () {
          final date = addDays(today, -i);
          final totals = DayTotals.of(entries, date);
          return _DayPoint(
            DateFormat('E d', locale).format(parseDateStr(date)),
            totals.consumed,
            totals.burned,
            totals.net,
          );
        }(),
    ];

    final values = [
      for (final d in days) ...[d.food, d.burn, d.net],
      goal,
    ];
    final minY = math.min(0.0, values.reduce(math.min));
    final maxRaw = math.max(1.0, values.reduce(math.max));
    final step = _niceStep((maxRaw - minY) / 4);
    final maxY = (maxRaw / step).ceil() * step;
    final minYNice = minY < 0 ? (minY / step).floor() * step : 0.0;

    final axisStyle = ts(
      10,
      mono: true,
      color: c.isLight ? c.text : NfColors.slate,
      weight: c.isLight ? w700 : FontWeight.w400,
    );
    final grid = FlGridData(
      drawVerticalLine: true,
      horizontalInterval: step,
      getDrawingHorizontalLine: (_) => FlLine(color: c.chartGrid, strokeWidth: 1, dashArray: c.isLight ? null : [3, 3]),
      getDrawingVerticalLine: (_) => FlLine(color: c.chartGrid, strokeWidth: 1, dashArray: c.isLight ? null : [3, 3]),
    );
    FlTitlesData titles({required bool visible}) => FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _leftReserved,
          interval: step,
          getTitlesWidget: (v, meta) => visible
              ? SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(fmtNum(v, maxDecimals: 0), style: axisStyle),
                )
              : const SizedBox.shrink(),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _bottomReserved,
          interval: 1,
          getTitlesWidget: (v, meta) {
            final i = v.round();
            if (!visible || i < 0 || i >= days.length || (v - i).abs() > 0.01) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(days[i].label, style: axisStyle),
            );
          },
        ),
      ),
    );

    final bars = BarChart(
      BarChartData(
        minY: minYNice,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: grid,
        borderData: FlBorderData(show: false),
        titlesData: titles(visible: true),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => c.isLight ? Colors.white : const Color(0xFF0B0E14),
            tooltipBorder: BorderSide(color: c.isLight ? c.border : c.chartGrid, width: c.isLight ? 2 : 1),
            tooltipBorderRadius: BorderRadius.circular(12),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, _, rod, rodIndex) {
              if (rodIndex != 0) return null;
              final d = days[group.x];
              return BarTooltipItem(
                '${d.label}\n',
                ts(11, weight: w700, mono: true, color: c.text),
                children: [
                  TextSpan(
                    text: '${t.chartsFoodIngested}: ${fmtNum(d.food)}\n',
                    style: ts(11, mono: true, color: NfColors.indigoLight),
                  ),
                  TextSpan(
                    text: '${t.chartsActiveBurn}: ${fmtNum(d.burn)}\n',
                    style: ts(11, mono: true, color: c.greenText),
                  ),
                  TextSpan(
                    text: '${t.chartsNetCalories}: ${fmtNum(d.net)}\n',
                    style: ts(11, mono: true, color: NfColors.roseSoft),
                  ),
                  TextSpan(
                    text: '${t.chartsGoal}: ${fmtNum(goal)}',
                    style: ts(11, mono: true, color: c.textMuted),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                BarChartRodData(
                  toY: days[i].food,
                  color: NfColors.indigo,
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: days[i].burn,
                  color: NfColors.green,
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );

    // The net + goal lines are a LineChart drawn over the bars with the same
    // axes; x = -0.5..6.5 puts each point at the centre of its bar group.
    final lines = IgnorePointer(
      child: LineChart(
        LineChartData(
          minX: -0.5,
          maxX: days.length - 0.5,
          minY: minYNice,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: titles(visible: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < days.length; i++) FlSpot(i.toDouble(), days[i].net)],
              isCurved: true,
              preventCurveOverShooting: true,
              color: NfColors.roseSoft,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) =>
                    FlDotCirclePainter(radius: 4, color: c.card, strokeWidth: 2, strokeColor: NfColors.roseSoft),
              ),
            ),
            LineChartBarData(
              spots: [FlSpot(-0.5, goal), FlSpot(days.length - 0.5, goal)],
              color: NfColors.slate,
              barWidth: 1,
              dashArray: const [5, 5],
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );

    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: ts(11, color: c.textBody, weight: c.isLight ? w700 : FontWeight.w400),
        ),
      ],
    );

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.chartsTrendTitle, icon: LucideIcons.trendingUp),
          const SizedBox(height: 4),
          Text(t.chartsTrendDesc, style: ts(10, color: c.textSecondary)),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              legend(NfColors.indigo, t.chartsFoodIngested),
              legend(NfColors.green, t.chartsActiveBurn),
              legend(NfColors.roseSoft, t.chartsNetCalories),
              legend(NfColors.slate, t.chartsGoal),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                Positioned.fill(child: bars),
                Positioned.fill(child: lines),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Round an axis step to 1/2/2.5/5 × 10^n so labels stay readable.
  static double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final exp = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final f = raw / exp;
    final nice = f <= 1
        ? 1
        : f <= 2
        ? 2
        : f <= 2.5
        ? 2.5
        : f <= 5
        ? 5
        : 10;
    return nice * exp;
  }
}

class _EnergyShare extends ConsumerWidget {
  const _EnergyShare();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final entries = ref.watch(appProvider.select((s) => s.entries));
    final totals = DayTotals.of(entries, todayStr());

    // kcal per gram: protein 4, carbs 4, fat 9.
    final pK = totals.protein * 4, cK = totals.carbs * 4, fK = totals.fat * 9;
    final total = pK + cK + fK;
    final empty = total == 0;
    final slices = empty
        ? [
            (t.chartsProtein, 30, const Color(0xFF10B981), 0),
            (t.chartsCarbs, 50, const Color(0xFFFBBF24), 0),
            (t.chartsFat, 20, const Color(0xFFF87171), 0),
          ]
        : [
            (t.chartsProtein, (pK / total * 100).round(), NfColors.green, totals.protein.round()),
            (t.chartsCarbs, (cK / total * 100).round(), NfColors.sky, totals.carbs.round()),
            (t.chartsFat, (fK / total * 100).round(), NfColors.yellow, totals.fat.round()),
          ];
    final grams = slices.fold<int>(0, (s, e) => s + e.$4);

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.chartsEnergyTitle, icon: LucideIcons.activity),
          const SizedBox(height: 4),
          Text(t.chartsEnergyDesc, style: ts(10, color: c.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 50,
                    sectionsSpace: 3,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(enabled: false),
                    sections: [
                      for (final (_, value, color, _) in slices)
                        PieChartSectionData(
                          value: math.max(value, 0.01).toDouble(),
                          color: color,
                          radius: 20,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${grams}g',
                      style: ts(20, weight: w700, color: c.text),
                    ),
                    Text(t.chartsTotalLogged.toUpperCase(), style: ts(9, color: c.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...spaced([
            for (final (name, value, color, g) in slices)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.isLight ? c.inset : const Color(0x660B0E14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.isLight ? c.insetBorder : c.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: ts(12, weight: w600, color: c.textBody),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${g}g',
                          style: ts(12, weight: w700, color: c.text),
                        ),
                        Text(t.chartsOfCalories('$value'), style: ts(9, color: c.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
          ], 10),
          if (empty) ...[const SizedBox(height: 10), MessageBox(t.chartsDefaultTemplate, kind: MessageKind.warning)],
        ],
      ),
    );
  }
}
