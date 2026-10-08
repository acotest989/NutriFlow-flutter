import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/day_totals.dart';
import '../../../core/format.dart';
import '../../../data/catalog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/catalog_items.dart';
import '../../../models/log_entry.dart';
import '../../../state/app_controller.dart';
import '../../../state/providers.dart';
import '../../entry_widgets.dart';
import '../../theme.dart';
import '../../widgets.dart';

enum _Mode { search, recent, manual }

/// Workouts: preset + wger search, recent quick-add, custom entry, and the
/// day's active log.
class ExerciseTab extends ConsumerStatefulWidget {
  const ExerciseTab({super.key});

  @override
  ConsumerState<ExerciseTab> createState() => _ExerciseTabState();
}

class _ExerciseTabState extends ConsumerState<ExerciseTab> {
  var _mode = _Mode.search;

  final _query = TextEditingController();
  Timer? _debounce;
  var _searchSeq = 0;
  List<ExerciseItem> _online = const [];
  var _searching = false;
  var _searchDone = false;

  final _cName = TextEditingController();
  final _cCalories = TextEditingController();
  final _cMinutes = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
    _cName.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_query, _cName, _cCalories, _cMinutes]) {
      c.dispose();
    }
    super.dispose();
  }

  // Debounced wger lookup (catalog is downloaded once, then searched locally).
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
      final res = await ref.read(exerciseDbProvider).search(q);
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searching = false;
        // null = catalog unavailable (offline / wger down): keep quiet.
        _online = res ?? const [];
        _searchDone = res != null;
      });
    });
  }

  AppController get _app => ref.read(appProvider.notifier);
  String get _date => ref.read(appProvider).currentDate;

  Future<void> _logCustom() async {
    final name = _cName.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    final minutes = (parseNum(_cMinutes.text) ?? 30).round();
    final ok = await _app.addEntry(
      NewEntry(
        date: _date,
        type: EntryType.exercise,
        name: '$name ($minutes mins)',
        calories: (parseNum(_cCalories.text) ?? 150).roundToDouble(),
        quantity: minutes.toDouble(),
      ),
    );
    if (!ok || !mounted) return;
    _cName.clear();
    _cCalories.clear();
    _cMinutes.text = '30';
    setState(() => _mode = _Mode.search);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.nf;
    return Column(
      children: spaced([
        NfSegmented<_Mode>(
          selected: _mode,
          activeColor: c.greenText,
          onChanged: (m) => setState(() => _mode = m),
          options: [
            SegmentOption(_Mode.search, t.exercisePresetWorkouts, LucideIcons.dumbbell),
            SegmentOption(_Mode.recent, t.commonRecent, LucideIcons.history),
            SegmentOption(_Mode.manual, t.exerciseCustomWorkout, LucideIcons.plus),
          ],
        ),
        switch (_mode) {
          _Mode.search => _searchCard(t),
          _Mode.recent => _recentCard(t),
          _Mode.manual => _customCard(t),
        },
        const _ActiveLog(),
      ], 16),
    );
  }

  Widget _exerciseRow(AppLocalizations t, ExerciseItem ex) {
    final c = context.nf;
    return CatalogRow(
      leading: IconTile(icon: LucideIcons.activity, color: c.greenText, size: 32, iconSize: 16),
      title: ex.name,
      subtitle: t.exerciseEstBurn(fmtNum(ex.caloriesPerMinute * 30, maxDecimals: 0)),
      trailing: Pill(
        '${fmtNum(ex.caloriesPerMinute)} kcal/min',
        mono: true,
        size: 11,
        weight: FontWeight.w400,
        borderColor: c.border,
      ),
      onTap: () => showAdjustSheet<void>(context, (_) => _DurationSheet(exercise: ex)),
    );
  }

  Widget _searchCard(AppLocalizations t) {
    final c = context.nf;
    final q = _query.text.trim().toLowerCase();
    final local = presetExercises.where((e) => e.name.toLowerCase().contains(q)).toList();
    final showOnline = _searching || _searchDone || _online.isNotEmpty;

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: t.exerciseCatalogTitle,
            trailing: Pill(t.exerciseActivities('${presetExercises.length}'), mono: true, weight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          NfTextField(
            controller: _query,
            hint: t.exerciseSearchPlaceholder,
            prefixIcon: LucideIcons.search,
            focusColor: NfColors.green,
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: local.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _exerciseRow(t, local[i]),
            ),
          ),
          if (showOnline) ...[
            const SizedBox(height: 16),
            OnlineResultsLabel(searching: _searching, spinnerColor: NfColors.green),
            const SizedBox(height: 8),
            for (final ex in _online) ...[_exerciseRow(t, ex), const SizedBox(height: 8)],
            if (!_searching && _searchDone && _online.isEmpty)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(t.foodNoOnlineMatches, style: ts(11, color: c.textMuted)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _recentCard(AppLocalizations t) {
    final c = context.nf;
    final recent = recentDistinct(ref.watch(appProvider.select((s) => s.entries)), EntryType.exercise);
    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.exerciseRecentTitle, trailing: Pill('${recent.length}', mono: true)),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                t.exerciseRecentEmpty,
                style: ts(12, color: c.textMuted),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...spaced([
              for (final ex in recent)
                CatalogRow(
                  key: ValueKey(ex.name.toLowerCase()),
                  leading: IconTile(icon: LucideIcons.activity, color: c.greenText, size: 32, iconSize: 16),
                  title: ex.name,
                  subtitle: '-${fmtNum(ex.calories)} kcal',
                  onTap: () {},
                  trailing: FlashAddButton(
                    color: NfColors.green,
                    foreground: const Color(0xFF0B0E14),
                    onAdd: () => _app.addEntry(
                      NewEntry(
                        date: _date,
                        type: EntryType.exercise,
                        name: ex.name,
                        calories: ex.calories,
                        quantity: ex.quantity,
                      ),
                    ),
                  ),
                ),
            ], 8),
        ],
      ),
    );
  }

  Widget _customCard(AppLocalizations t) {
    Widget field(String label, TextEditingController ctl, String hint, {bool number = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        NfTextField(
          controller: ctl,
          hint: hint,
          dense: true,
          focusColor: NfColors.green,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          inputFormatters: number ? NfTextField.integerFormatters : null,
        ),
      ],
    );
    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.exerciseLogCustomTitle, icon: LucideIcons.activity, iconColor: context.nf.greenText),
          const SizedBox(height: 16),
          field(t.exerciseExerciseDesc, _cName, t.exercisePhExerciseName),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field(t.exerciseCaloriesBurned, _cCalories, t.exercisePhCaloriesBurned, number: true)),
              const SizedBox(width: 12),
              Expanded(child: field(t.exerciseDuration, _cMinutes, t.exercisePhDuration, number: true)),
            ],
          ),
          const SizedBox(height: 16),
          NfButton(
            label: t.exerciseLogCustomBtn,
            variant: NfButtonVariant.green,
            expand: true,
            onPressed: _cName.text.trim().isEmpty ? null : _logCustom,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: pick the workout duration, then log the estimated burn.
class _DurationSheet extends ConsumerStatefulWidget {
  const _DurationSheet({required this.exercise});
  final ExerciseItem exercise;

  @override
  ConsumerState<_DurationSheet> createState() => _DurationSheetState();
}

class _DurationSheetState extends ConsumerState<_DurationSheet> {
  var _minutes = 30;

  Future<void> _log() async {
    final ex = widget.exercise;
    final minutes = _minutes;
    Navigator.of(context).pop();
    await ref
        .read(appProvider.notifier)
        .addEntry(
          NewEntry(
            date: ref.read(appProvider).currentDate,
            type: EntryType.exercise,
            name: '${ex.name} ($minutes mins)',
            calories: (ex.caloriesPerMinute * minutes).roundToDouble(),
            quantity: minutes.toDouble(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final burn = (widget.exercise.caloriesPerMinute * _minutes).round();
    return Theme(
      data: Theme.of(context).copyWith(
        sliderTheme: Theme.of(context).sliderTheme.copyWith(
          activeTrackColor: NfColors.green,
          thumbColor: NfColors.green,
          overlayColor: NfColors.green.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.exercise.name,
            style: ts(16, weight: w700, color: c.text),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.exerciseAdjustDuration,
                  style: ts(12, weight: w700, color: c.greenText),
                ),
              ),
              Icon(LucideIcons.watch, size: 14, color: c.greenText),
              const SizedBox(width: 4),
              Text(
                t.exerciseMinutes('$_minutes'),
                style: ts(12, weight: w700, mono: true, color: c.textSecondary),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _minutes.toDouble(),
                  min: 5,
                  max: 180,
                  divisions: 35,
                  onChanged: (v) => setState(() => _minutes = v.round()),
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
                  '${_minutes}m',
                  textAlign: TextAlign.center,
                  style: ts(14, weight: w700, color: c.greenText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          NfInset(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.exerciseActiveMinutes, style: ts(12, color: c.textMuted)),
                      Text(
                        t.exerciseMins('$_minutes'),
                        style: ts(14, weight: w700, color: c.text),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(t.exerciseNegativeCalories, style: ts(12, color: c.greenText)),
                    Text(
                      '-$burn kcal',
                      style: ts(16, weight: w700, color: c.greenText),
                    ),
                  ],
                ),
              ],
            ),
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
                child: NfButton(
                  label: t.exerciseLogExercise,
                  variant: NfButtonVariant.green,
                  expand: true,
                  onPressed: _log,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveLog extends ConsumerWidget {
  const _ActiveLog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final s = ref.watch(appProvider);
    final logged = s.entries.where((e) => e.date == s.currentDate && !e.isMeal).toList();
    final total = logged.fold<double>(0, (sum, e) => sum + e.calories);

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: t.exerciseActiveLogTitle,
            icon: LucideIcons.flame,
            iconColor: c.greenText,
            trailing: Pill(
              '-${fmtNum(total)} ${t.exerciseKcalToday}',
              size: 12,
              color: c.greenText,
              background: NfColors.green.withValues(alpha: 0.1),
              borderColor: NfColors.green.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 16),
          if (logged.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                t.exerciseNoWorkouts,
                style: ts(12, color: c.textMuted),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...spaced([
              for (final ex in logged)
                LoggedRow(
                  key: ValueKey(ex.id),
                  leading: IconTile(
                    icon: LucideIcons.flame,
                    color: c.greenText,
                    size: 28,
                    iconSize: 16,
                    radius: 8,
                    bordered: true,
                  ),
                  title: ex.name,
                  subtitle: t.exerciseDurationValue(fmtNum(ex.quantity)),
                  kcalLabel: '-${fmtNum(ex.calories)} kcal',
                  kcalColor: c.greenText,
                  deleteTooltip: t.exerciseDeleteEntry,
                  onDelete: () => ref.read(appProvider.notifier).removeEntry(ex.id),
                ),
            ], 12),
        ],
      ),
    );
  }
}
