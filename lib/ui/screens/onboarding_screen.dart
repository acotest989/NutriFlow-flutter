import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../core/goal_calc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../models/profile.dart';
import '../../state/app_controller.dart';
import '../errors.dart';
import '../labels.dart';
import '../theme.dart';
import '../widgets.dart';

/// Personalization quiz. Modes:
///  - first run (no args): saves via completeOnboarding; the gate then shows the app.
///  - edit ([initial] + [editing]): pre-filled; pops when saved or cancelled.
///  - promo ([onSubmit] + [secondaryLabel]): logged-out; [onSubmit] stashes the
///    answers, then pops `true` so the auth screen can switch to sign-up.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.initial,
    this.editing = false,
    this.onSubmit,
    this.submitLabel,
    this.title,
    this.secondaryLabel,
  });

  final Profile? initial;
  final bool editing;
  final Future<AppError?> Function(OnboardingData data)? onSubmit;
  final String? submitLabel;
  final String? title;
  final String? secondaryLabel;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 7;

  var _step = 0;
  var _saving = false;
  String? _error;

  GoalType? _goalType;
  Sex? _sex;
  late Units _units;
  ActivityLevel? _activity;
  late DietPreference _diet;
  late List<String> _restrictions;
  late List<String> _workouts;

  final _age = TextEditingController();
  // Body fields — metric and imperial kept in sync on unit toggle.
  final _cm = TextEditingController();
  final _kg = TextEditingController();
  final _targetKg = TextEditingController();
  final _ft = TextEditingController();
  final _inch = TextEditingController();
  final _lb = TextEditingController();
  final _targetLb = TextEditingController();

  List<TextEditingController> get _all => [_age, _cm, _kg, _targetKg, _ft, _inch, _lb, _targetLb];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _goalType = p?.goalType;
    _sex = p?.sex;
    _units = p?.units ?? Units.metric;
    _activity = p?.activity;
    _diet = p?.diet ?? DietPreference.none;
    _restrictions = [...?p?.restrictions];
    _workouts = [...?p?.workouts];
    if (p != null) {
      _age.text = fmtNum(p.age, maxDecimals: 0);
      if (p.units == Units.metric) {
        _cm.text = fmtNum(p.heightCm.roundToDouble());
        _kg.text = fmtNum(p.weightKg);
        if (p.targetWeightKg != null) _targetKg.text = fmtNum(p.targetWeightKg!);
      } else {
        final h = cmToFtIn(p.heightCm);
        _ft.text = '${h.ft}';
        _inch.text = '${h.inches}';
        _lb.text = '${kgToLb(p.weightKg).round()}';
        if (p.targetWeightKg != null) _targetLb.text = '${kgToLb(p.targetWeightKg!).round()}';
      }
    }
    for (final ctl in _all) {
      ctl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctl in _all) {
      ctl.dispose();
    }
    super.dispose();
  }

  double _n(TextEditingController ctl) => parseNum(ctl.text) ?? 0;

  void _toggleUnits(Units to) {
    if (to == _units) return;
    setState(() {
      if (to == Units.imperial) {
        if (_cm.text.isNotEmpty) {
          final h = cmToFtIn(_n(_cm));
          _ft.text = '${h.ft}';
          _inch.text = '${h.inches}';
        }
        if (_kg.text.isNotEmpty) _lb.text = '${kgToLb(_n(_kg)).round()}';
        if (_targetKg.text.isNotEmpty) _targetLb.text = '${kgToLb(_n(_targetKg)).round()}';
      } else {
        if (_ft.text.isNotEmpty || _inch.text.isNotEmpty) _cm.text = '${ftInToCm(_n(_ft), _n(_inch)).round()}';
        if (_lb.text.isNotEmpty) _kg.text = '${lbToKg(_n(_lb)).round()}';
        if (_targetLb.text.isNotEmpty) _targetKg.text = '${lbToKg(_n(_targetLb)).round()}';
      }
      _units = to;
    });
  }

  double get _heightCm => _units == Units.metric ? _n(_cm) : ftInToCm(_n(_ft), _n(_inch));
  double get _weightKg => _units == Units.metric ? _n(_kg) : lbToKg(_n(_lb));

  OnboardingData _toMetric() => OnboardingData(
    goalType: _goalType ?? GoalType.maintain,
    sex: _sex ?? Sex.other,
    age: _n(_age),
    heightCm: _heightCm,
    weightKg: _weightKg,
    targetWeightKg: _units == Units.metric
        ? (_targetKg.text.isEmpty ? null : _n(_targetKg))
        : (_targetLb.text.isEmpty ? null : lbToKg(_n(_targetLb))),
    activity: _activity ?? ActivityLevel.moderate,
    diet: _diet,
    restrictions: _restrictions,
    workouts: _workouts,
    units: _units,
  );

  // Per-step validation gating the Continue button.
  bool get _canNext => switch (_step) {
    0 => _goalType != null,
    1 => _sex != null && _n(_age) >= 13 && _n(_age) <= 100,
    2 => _heightCm >= 120 && _heightCm <= 250 && _weightKg >= 30 && _weightKg <= 400,
    3 => _activity != null,
    _ => true,
  };

  bool get _isLast => _step == _steps - 1;

  Future<void> _finish() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    final submit = widget.onSubmit ?? ref.read(appProvider.notifier).completeOnboarding;
    final err = await submit(_toMetric());
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = appErrorText(AppLocalizations.of(context), err);
        _saving = false;
      });
      return;
    }
    // First run: the gate swaps to the dashboard. Edit/promo: close the page.
    if (widget.editing || widget.onSubmit != null) Navigator.of(context).pop(true);
  }

  void _secondary() {
    if (widget.secondaryLabel != null || widget.editing) {
      Navigator.of(context).pop(false);
    } else {
      ref.read(appProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final stepNames = [
      t.onboardingStepsGoal,
      t.onboardingStepsAbout,
      t.onboardingStepsBody,
      t.onboardingStepsActivity,
      t.onboardingStepsDiet,
      t.onboardingStepsPrefs,
      t.onboardingStepsReview,
    ];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0 && !_saving) setState(() => _step--);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const BrandMark(size: 40, radius: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title ?? (widget.editing ? t.onboardingEditTitle : t.onboardingPersonalizeTitle),
                                style: ts(14, weight: w900, color: c.text),
                              ),
                              Text(
                                '${t.onboardingStepOf('${_step + 1}', '$_steps')} · ${stepNames[_step]}',
                                style: ts(11, color: c.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ProgressBar(value: (_step + 1) / _steps),
                    const SizedBox(height: 24),
                    NfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: KeyedSubtree(key: ValueKey(_step), child: _stepBody(t, c)),
                          ),
                          if (_error != null) ...[const SizedBox(height: 16), MessageBox(_error!)],
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              if (_step > 0) ...[
                                NfButton(
                                  label: t.onboardingBack,
                                  icon: LucideIcons.chevronLeft,
                                  variant: NfButtonVariant.ghost,
                                  onPressed: _saving ? null : () => setState(() => _step--),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: _isLast
                                    ? NfButton(
                                        expand: true,
                                        loading: _saving,
                                        icon: LucideIcons.check,
                                        label: _saving
                                            ? t.onboardingSaving
                                            : widget.submitLabel ??
                                                  (widget.editing
                                                      ? t.onboardingSaveChanges
                                                      : t.onboardingStartTracking),
                                        onPressed: _finish,
                                      )
                                    : NfButton(
                                        expand: true,
                                        label: t.onboardingContinue,
                                        icon: LucideIcons.chevronRight,
                                        onPressed: _canNext ? () => setState(() => _step++) : null,
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _saving ? null : _secondary,
                      child: Text(
                        widget.secondaryLabel ?? (widget.editing ? t.commonCancel : t.onboardingSignOut),
                        style: ts(11, color: c.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody(AppLocalizations t, NfColors c) {
    switch (_step) {
      case 0:
        return _Section(
          icon: LucideIcons.target,
          title: t.onboardingStep0Title,
          child: _Grid(
            columns: 2,
            children: [
              for (final g in GoalType.values)
                _OptionCard(
                  active: _goalType == g,
                  onTap: () => setState(() => _goalType = g),
                  title: goalLabel(t, g),
                  hint: goalHint(t, g),
                ),
            ],
          ),
        );
      case 1:
        return _Section(
          icon: LucideIcons.flame,
          title: t.onboardingStep1Title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UnitToggle(units: _units, onChanged: _toggleUnits),
              const SizedBox(height: 16),
              FieldLabel(t.onboardingSexLabel),
              _Grid(
                columns: 3,
                children: [
                  for (final s in Sex.values)
                    _OptionCard(
                      active: _sex == s,
                      onTap: () => setState(() => _sex = s),
                      title: sexLabel(t, s),
                      compact: true,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FieldLabel(t.onboardingAgeLabel),
              NfTextField(
                controller: _age,
                hint: t.onboardingAgePlaceholder,
                keyboardType: TextInputType.number,
                inputFormatters: NfTextField.integerFormatters,
              ),
            ],
          ),
        );
      case 2:
        final metric = _units == Units.metric;
        Widget numField(TextEditingController ctl, String hint, String suffix, {bool decimal = false}) => NfTextField(
          controller: ctl,
          hint: hint,
          suffixText: suffix,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: decimal ? NfTextField.decimalFormatters : NfTextField.integerFormatters,
        );
        return _Section(
          icon: LucideIcons.activity,
          title: t.onboardingStep2Title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UnitToggle(units: _units, onChanged: _toggleUnits),
              const SizedBox(height: 16),
              FieldLabel(t.onboardingHeightLabel),
              if (metric)
                numField(_cm, '175', 'cm')
              else
                Row(
                  children: [
                    Expanded(child: numField(_ft, '5', 'ft')),
                    const SizedBox(width: 12),
                    Expanded(child: numField(_inch, '9', 'in')),
                  ],
                ),
              const SizedBox(height: 16),
              FieldLabel(t.onboardingCurrentWeightLabel),
              metric ? numField(_kg, '72', 'kg', decimal: true) : numField(_lb, '160', 'lb', decimal: true),
              const SizedBox(height: 16),
              FieldLabel('${t.onboardingTargetWeightLabel} ${t.onboardingOptional}'),
              metric ? numField(_targetKg, '68', 'kg', decimal: true) : numField(_targetLb, '150', 'lb', decimal: true),
            ],
          ),
        );
      case 3:
        return _Section(
          icon: LucideIcons.activity,
          title: t.onboardingStep3Title,
          child: Column(
            children: spaced([
              for (final a in ActivityLevel.values)
                _OptionCard(
                  active: _activity == a,
                  onTap: () => setState(() => _activity = a),
                  title: activityLabel(t, a),
                  hint: activityHint(t, a),
                  row: true,
                ),
            ], 8),
          ),
        );
      case 4:
        return _Section(
          icon: LucideIcons.salad,
          title: t.onboardingStep4Title,
          child: _Grid(
            columns: 2,
            children: [
              for (final d in DietPreference.values)
                _OptionCard(
                  active: _diet == d,
                  onTap: () => setState(() => _diet = d),
                  title: dietLabel(t, d),
                  compact: true,
                ),
            ],
          ),
        );
      case 5:
        void toggle(List<String> list, String v) => setState(() => list.contains(v) ? list.remove(v) : list.add(v));
        return _Section(
          icon: LucideIcons.dumbbell,
          title: t.onboardingStep5Title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldLabel(t.onboardingRestrictionsLabel),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in restrictionOptions)
                    _Chip(
                      label: restrictionLabel(t, r),
                      active: _restrictions.contains(r),
                      onTap: () => toggle(_restrictions, r),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FieldLabel(t.onboardingWorkoutsLabel),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final w in workoutOptions)
                    _Chip(label: workoutLabel(t, w), active: _workouts.contains(w), onTap: () => toggle(_workouts, w)),
                ],
              ),
            ],
          ),
        );
      default:
        final goal = computeGoal(_toMetric());
        return _Section(
          icon: LucideIcons.check,
          title: t.onboardingStep6Title,
          child: Column(
            children: [
              _ReviewCard(goal: goal),
              const SizedBox(height: 12),
              Text(
                t.onboardingReviewNote,
                style: ts(11, color: c.textMuted, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.goal});
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    Widget macro(String label, double value, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: c.subtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Text(
              '${fmtNum(value)}g',
              style: ts(18, weight: w900, color: color),
            ),
            Text(label.toUpperCase(), style: ts(10, color: c.textMuted, letterSpacing: 0.8)),
          ],
        ),
      ),
    );
    return NfInset(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(t.onboardingDailyCalories.toUpperCase(), style: ts(11, color: c.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: fmtNum(goal.calories),
                  style: ts(36, weight: w900, color: c.text),
                ),
                TextSpan(
                  text: ' kcal',
                  style: ts(14, weight: w600, color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              macro(t.onboardingProtein, goal.protein, c.emeraldText),
              const SizedBox(width: 8),
              macro(t.onboardingCarbs, goal.carbs, c.isLight ? c.amberText : const Color(0xFFFBBF24)),
              const SizedBox(width: 8),
              macro(t.onboardingFat, goal.fat, c.roseText),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: Container(
      height: 6,
      color: context.nf.subtle,
      alignment: Alignment.centerLeft,
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 300),
        widthFactor: value,
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [NfColors.indigo, NfColors.purple])),
        ),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeader(title: title, icon: icon, size: 14),
      const SizedBox(height: 16),
      child,
    ],
  );
}

/// Equal-width grid whose rows stretch to the tallest cell.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});
  final int columns;
  final List<Widget> children;
  static const gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = children.sublist(i, (i + columns).clamp(0, children.length));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) const SizedBox(width: gap),
                Expanded(child: j < cells.length ? cells[j] : const SizedBox()),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: spaced(rows, gap));
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.active,
    required this.onTap,
    required this.title,
    this.hint,
    this.compact = false,
    this.row = false,
  });

  final bool active;
  final VoidCallback onTap;
  final String title;
  final String? hint;
  final bool compact;
  final bool row;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final titleW = Text(
      title,
      style: ts(14, weight: compact || row ? w600 : w700, color: c.text),
    );
    final hintW = hint == null ? null : Text(hint!, style: ts(11, color: c.textSecondary));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 10 : 14),
          decoration: BoxDecoration(
            color: active ? NfColors.indigo.withValues(alpha: c.isLight ? 0.15 : 0.1) : c.inset,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? NfColors.indigo : c.borderStrong,
              width: active ? 1.5 : (c.isLight ? 1.5 : 1),
            ),
          ),
          child: row
              ? Row(
                  children: [
                    Expanded(child: titleW),
                    if (hintW != null) ...[const SizedBox(width: 12), Flexible(child: hintW)],
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleW,
                    if (hintW != null) ...[const SizedBox(height: 2), hintW],
                  ],
                ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? NfColors.indigo.withValues(alpha: 0.15) : c.inset,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? NfColors.indigo : c.borderStrong),
        ),
        child: Text(
          label,
          style: ts(12, weight: w600, color: active ? c.text : c.textSecondary),
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.units, required this.onChanged});
  final Units units;
  final ValueChanged<Units> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.inset,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final u in Units.values)
            GestureDetector(
              onTap: () => onChanged(u),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: units == u ? c.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  u == Units.metric ? t.onboardingMetric : t.onboardingImperial,
                  style: ts(12, weight: w600, color: units == u ? c.onPrimary : c.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
