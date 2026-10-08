import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/date_utils.dart';
import '../../../core/day_totals.dart';
import '../../../core/format.dart';
import '../../../data/catalog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/catalog_items.dart';
import '../../../models/log_entry.dart';
import '../../../state/app_controller.dart';
import '../../../state/providers.dart';
import '../../../state/settings_controller.dart';
import '../../entry_widgets.dart';
import '../../errors.dart';
import '../../theme.dart';
import '../../widgets.dart';

enum _Mode { search, recent, manual }

/// Meals: database search (local + USDA), recent quick-add, AI estimate +
/// manual entry, and the day's logged meal history.
class MealsTab extends ConsumerStatefulWidget {
  const MealsTab({super.key});

  @override
  ConsumerState<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends ConsumerState<MealsTab> {
  var _mode = _Mode.search;

  // Search
  final _query = TextEditingController();
  Timer? _debounce;
  var _searchSeq = 0;
  List<FoodItem> _online = const [];
  var _searching = false;
  var _searchDone = false;

  // AI estimate
  final _aiInput = TextEditingController();
  var _aiLoading = false;
  FoodItem? _aiResult;
  String? _aiError;

  // Manual entry
  final _mName = TextEditingController();
  final _mServing = TextEditingController(text: '100');
  final _mUnit = TextEditingController(text: 'g');
  final _mCal = TextEditingController();
  final _mProtein = TextEditingController();
  final _mCarbs = TextEditingController();
  final _mFat = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
    _aiInput.addListener(() => setState(() {}));
    _mName.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_query, _aiInput, _mName, _mServing, _mUnit, _mCal, _mProtein, _mCarbs, _mFat]) {
      c.dispose();
    }
    super.dispose();
  }

  // Debounced USDA lookup; a newer keystroke invalidates older responses.
  void _onQueryChanged() {
    setState(() {});
    _debounce?.cancel();
    final q = _query.text.trim();
    final seq = ++_searchSeq;
    if (q.length < 2) {
      setState(() {
        _online = const [];
        _searching = false;
        _searchDone = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _searchDone = false;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final res = await ref.read(foodDbProvider).searchUsda(q);
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searching = false;
        _online = res ?? const [];
        _searchDone = res != null; // network error: no "no matches" hint
      });
    });
  }

  String get _date => ref.read(appProvider).currentDate;
  AppController get _app => ref.read(appProvider.notifier);

  Future<void> _openPortion(FoodItem food) => showAdjustSheet<void>(context, (_) => _PortionSheet(food: food));

  Future<void> _aiEstimate() async {
    final text = _aiInput.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context);
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _aiResult = null;
    });
    try {
      final r = await ref.read(aiServiceProvider).estimateFood(text, ref.read(settingsProvider).language);
      if (mounted) setState(() => _aiResult = r);
    } catch (e) {
      if (mounted) setState(() => _aiError = aiErrorText(t, e, t.foodAiError));
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _logAi() async {
    final r = _aiResult;
    if (r == null) return;
    final ok = await _app.addEntry(
      NewEntry(
        date: _date,
        type: EntryType.meal,
        name: '${r.name} (AI)',
        calories: r.calories,
        protein: r.protein,
        carbs: r.carbs,
        fat: r.fat,
        quantity: r.servingSize,
      ),
    );
    if (ok && mounted) {
      setState(() => _aiResult = null);
      _aiInput.clear();
    }
  }

  Future<void> _logManual() async {
    final name = _mName.text.trim();
    if (name.isEmpty) return;
    final size = (parseNum(_mServing.text) ?? 100).roundToDouble();
    final unit = _mUnit.text.trim();
    FocusScope.of(context).unfocus();
    final ok = await _app.addEntry(
      NewEntry(
        date: _date,
        type: EntryType.meal,
        // No unit column on entries, so the serving is kept in the name.
        name: unit.isNotEmpty ? '$name (${fmtNum(size)} $unit)' : name,
        calories: (parseNum(_mCal.text) ?? 0).roundToDouble(),
        protein: parseNum(_mProtein.text) ?? 0,
        carbs: parseNum(_mCarbs.text) ?? 0,
        fat: parseNum(_mFat.text) ?? 0,
        quantity: size,
      ),
    );
    if (!ok || !mounted) return;
    for (final c in [_mName, _mCal, _mProtein, _mCarbs, _mFat]) {
      c.clear();
    }
    _mServing.text = '100';
    _mUnit.text = 'g';
    setState(() => _mode = _Mode.search);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: spaced([
        NfSegmented<_Mode>(
          selected: _mode,
          onChanged: (m) => setState(() => _mode = m),
          options: [
            SegmentOption(_Mode.search, t.foodDbLookup, LucideIcons.database),
            SegmentOption(_Mode.recent, t.commonRecent, LucideIcons.history),
            SegmentOption(_Mode.manual, t.foodManualAiLog, LucideIcons.plus),
          ],
        ),
        switch (_mode) {
          _Mode.search => _searchCard(t),
          _Mode.recent => _recentCard(t),
          _Mode.manual => Column(children: spaced([_aiCard(t), _manualCard(t)], 16)),
        },
        const _MealHistory(),
      ], 16),
    );
  }

  String _foodSubtitle(AppLocalizations t, FoodItem f) =>
      '${t.foodServing} ${fmtNum(f.servingSize)}${f.servingUnit} • P: ${fmtNum(f.protein)}g • C: ${fmtNum(f.carbs)}g • F: ${fmtNum(f.fat)}g';

  Widget _kcalPill(NfColors c, double kcal) => Pill(
    '${fmtNum(kcal)} kcal',
    size: 14,
    color: c.accent,
    background: NfColors.indigo.withValues(alpha: 0.1),
    borderColor: NfColors.indigo.withValues(alpha: 0.1),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  );

  Widget _searchCard(AppLocalizations t) {
    final c = context.nf;
    final q = _query.text.trim().toLowerCase();
    final local = commonFoodItems.where((f) => f.name.toLowerCase().contains(q)).toList();
    final showOnline = _searching || _searchDone || _online.isNotEmpty;

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: t.foodDbSearchTitle,
            trailing: Pill(t.foodItemsLoaded('${commonFoodItems.length}'), mono: true, weight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          NfTextField(
            controller: _query,
            hint: t.foodSearchPlaceholder,
            prefixIcon: LucideIcons.search,
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: local.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      t.foodNoMatch,
                      style: ts(12, color: c.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: local.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => CatalogRow(
                      title: local[i].name,
                      subtitle: _foodSubtitle(t, local[i]),
                      trailing: _kcalPill(c, local[i].calories),
                      onTap: () => _openPortion(local[i]),
                    ),
                  ),
          ),
          if (showOnline) ...[
            const SizedBox(height: 16),
            OnlineResultsLabel(searching: _searching),
            const SizedBox(height: 8),
            for (final f in _online) ...[
              CatalogRow(
                title: f.name,
                subtitle: _foodSubtitle(t, f),
                trailing: _kcalPill(c, f.calories),
                onTap: () => _openPortion(f),
              ),
              const SizedBox(height: 8),
            ],
            if (!_searching && _searchDone && _online.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(t.foodNoOnlineMatches, style: ts(11, color: c.textMuted)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _recentCard(AppLocalizations t) {
    final c = context.nf;
    final recent = recentDistinct(ref.watch(appProvider.select((s) => s.entries)), EntryType.meal);
    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.foodRecentTitle, trailing: Pill('${recent.length}', mono: true)),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                t.foodRecentEmpty,
                style: ts(12, color: c.textMuted),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...spaced([
              for (final m in recent)
                CatalogRow(
                  key: ValueKey(m.name.toLowerCase()),
                  title: m.name,
                  subtitle:
                      '${fmtNum(m.calories)} kcal • P: ${fmtNum(m.protein)}g • C: ${fmtNum(m.carbs)}g • F: ${fmtNum(m.fat)}g',
                  onTap: () {},
                  trailing: FlashAddButton(
                    onAdd: () => _app.addEntry(
                      NewEntry(
                        date: _date,
                        type: EntryType.meal,
                        name: m.name,
                        calories: m.calories,
                        protein: m.protein,
                        carbs: m.carbs,
                        fat: m.fat,
                        quantity: m.quantity,
                      ),
                    ),
                  ),
                ),
            ], 8),
        ],
      ),
    );
  }

  Widget _aiCard(AppLocalizations t) {
    final c = context.nf;
    final r = _aiResult;
    return NfCard(
      gradient: c.isLight
          ? null
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x661E1B4B), Color(0xFF141923), Color(0xFF0B0E14)],
            ),
      borderColor: c.isLight ? null : c.borderStrong,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Opacity(opacity: 0.15, child: Icon(LucideIcons.sparkles, size: 160, color: c.accent)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: t.foodAiTitle, icon: LucideIcons.sparkles, size: 16),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: ts(12, color: c.isLight ? c.textBody : const Color(0xFFCBD5E1), height: 1.5),
                  children: [
                    TextSpan(text: '${t.foodAiDesc} '),
                    TextSpan(
                      text: '"${t.foodAiExample}"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NfTextField(controller: _aiInput, hint: t.foodAiPlaceholder, maxLines: 3, minLines: 2),
              const SizedBox(height: 12),
              NfButton(
                expand: true,
                loading: _aiLoading,
                label: _aiLoading ? t.foodAiAnalyzing : t.foodAiEstimateBtn,
                leading: const Icon(LucideIcons.sparkles, size: 16, color: Color(0xFFFCD34D)),
                onPressed: _aiInput.text.trim().isEmpty || _aiLoading ? null : _aiEstimate,
              ),
              if (_aiError != null) ...[const SizedBox(height: 12), MessageBox(_aiError!)],
              if (r != null) ...[
                const SizedBox(height: 16),
                NfInset(
                  padding: const EdgeInsets.all(16),
                  borderColor: c.isLight ? null : c.borderStrong,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Pill(
                                  t.foodAiExtracted.toUpperCase(),
                                  size: 9,
                                  color: c.accent,
                                  background: NfColors.indigo.withValues(alpha: 0.2),
                                  weight: w600,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  r.name,
                                  style: ts(14, weight: w700, color: c.text),
                                ),
                                Text(
                                  '${t.foodPortionSize} ${fmtNum(r.servingSize)}${r.servingUnit}',
                                  style: ts(10, color: c.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${fmtNum(r.calories)} kcal',
                            style: ts(16, weight: w700, color: c.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MacroGrid(
                        items: [
                          (t.foodProtein, '${fmtNum(r.protein)}g', NfColors.orange),
                          (t.foodCarbs, '${fmtNum(r.carbs)}g', NfColors.sky),
                          (t.foodFat, '${fmtNum(r.fat)}g', NfColors.yellow),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: NfButton(
                              label: t.foodDiscard,
                              variant: NfButtonVariant.secondary,
                              expand: true,
                              small: true,
                              onPressed: () => setState(() => _aiResult = null),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NfButton(
                              label: t.foodLogAiMeal,
                              icon: LucideIcons.check,
                              expand: true,
                              small: true,
                              onPressed: _logAi,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _manualCard(AppLocalizations t) {
    Widget field(String label, TextEditingController ctl, {String? hint, bool number = false, bool decimal = false}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label),
            NfTextField(
              controller: ctl,
              hint: hint,
              dense: true,
              keyboardType: number ? TextInputType.numberWithOptions(decimal: decimal) : TextInputType.text,
              inputFormatters: number
                  ? (decimal ? NfTextField.decimalFormatters : NfTextField.integerFormatters)
                  : null,
            ),
          ],
        );
    Widget pair(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.foodManualTitle, icon: LucideIcons.scale),
          const SizedBox(height: 16),
          field(t.foodFoodName, _mName, hint: t.foodPhName),
          const SizedBox(height: 12),
          pair(
            field(t.foodServingSize, _mServing, hint: t.foodPhServing, number: true),
            field(t.foodUnit, _mUnit, hint: 'g'),
          ),
          const SizedBox(height: 12),
          pair(
            field(t.foodCaloriesKcal, _mCal, hint: t.foodPhCalories, number: true),
            field(t.foodProteinG, _mProtein, hint: t.foodPhProtein, number: true, decimal: true),
          ),
          const SizedBox(height: 12),
          pair(
            field(t.foodCarbsG, _mCarbs, hint: t.foodPhCarbs, number: true, decimal: true),
            field(t.foodFatsG, _mFat, hint: t.foodPhFat, number: true, decimal: true),
          ),
          const SizedBox(height: 16),
          NfButton(label: t.foodLogCustomFood, expand: true, onPressed: _mName.text.trim().isEmpty ? null : _logManual),
        ],
      ),
    );
  }
}

/// Bottom sheet: pick a portion multiplier, then log.
class _PortionSheet extends ConsumerStatefulWidget {
  const _PortionSheet({required this.food});
  final FoodItem food;

  @override
  ConsumerState<_PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends ConsumerState<_PortionSheet> {
  var _multiplier = 1.0;

  Future<void> _log() async {
    final f = widget.food;
    final m = _multiplier;
    Navigator.of(context).pop();
    await ref
        .read(appProvider.notifier)
        .addEntry(
          NewEntry(
            date: ref.read(appProvider).currentDate,
            type: EntryType.meal,
            name: '${f.name} (x${fmtNum(m, maxDecimals: 2)})',
            calories: (f.calories * m).roundToDouble(),
            protein: round1(f.protein * m),
            carbs: round1(f.carbs * m),
            fat: round1(f.fat * m),
            quantity: (f.servingSize * m).roundToDouble(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final f = widget.food;
    final m = _multiplier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          f.name,
          style: ts(16, weight: w700, color: c.text),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                t.foodAdjustPortion,
                style: ts(12, weight: w700, color: c.accent),
              ),
            ),
            Text.rich(
              TextSpan(
                style: ts(12, mono: true, color: c.textSecondary),
                children: [
                  TextSpan(text: '${t.foodTotal} '),
                  TextSpan(
                    text: '${fmtNum((f.servingSize * m).roundToDouble())} ${f.servingUnit}',
                    style: const TextStyle(fontWeight: w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: m,
                min: 0.25,
                max: 5,
                divisions: 19,
                onChanged: (v) => setState(() => _multiplier = v),
              ),
            ),
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: c.inset,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.borderStrong),
              ),
              child: Text(
                '${fmtNum(m, maxDecimals: 2)}x',
                textAlign: TextAlign.center,
                style: ts(14, weight: w700, color: c.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MacroGrid(
          items: [
            (t.foodKcal, fmtNum((f.calories * m).roundToDouble()), c.textMuted),
            (t.foodProtein, '${fmtNum(round1(f.protein * m))}g', NfColors.orange),
            (t.foodCarbs, '${fmtNum(round1(f.carbs * m))}g', NfColors.sky),
            (t.foodFat, '${fmtNum(round1(f.fat * m))}g', NfColors.yellow),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NfButton(
                label: t.commonCancel,
                variant: NfButtonVariant.secondary,
                expand: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: NfButton(label: t.foodLogNamed(f.name), expand: true, onPressed: _log),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealHistory extends ConsumerWidget {
  const _MealHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final s = ref.watch(appProvider);
    final meals = s.entries.where((e) => e.date == s.currentDate && e.isMeal).toList();
    final today = todayStr();
    final dateLabel = s.currentDate == today
        ? t.foodTodayLower
        : s.currentDate == addDays(today, -1)
        ? t.foodYesterdayLower
        : s.currentDate;

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.foodHistoryTitle, icon: LucideIcons.utensils),
          const SizedBox(height: 16),
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                t.foodNoLogs(dateLabel),
                style: ts(12, color: c.textMuted),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...spaced([
              for (final m in meals)
                LoggedRow(
                  key: ValueKey(m.id),
                  title: m.name,
                  subtitle:
                      '${t.foodPortion} ${fmtNum(m.quantity)}g • P: ${fmtNum(m.protein)}g • C: ${fmtNum(m.carbs)}g • F: ${fmtNum(m.fat)}g',
                  kcalLabel: '${fmtNum(m.calories)} kcal',
                  deleteTooltip: t.foodDeleteEntry,
                  onDelete: () => ref.read(appProvider.notifier).removeEntry(m.id),
                ),
            ], 12),
        ],
      ),
    );
  }
}
