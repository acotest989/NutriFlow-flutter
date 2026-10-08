import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/ai_prefs.dart';
import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/log_entry.dart';
import '../../../services/ai_service.dart';
import '../../../state/app_controller.dart';
import '../../../state/providers.dart';
import '../../../state/settings_controller.dart';
import '../../errors.dart';
import '../../theme.dart';
import '../../widgets.dart';

enum _Mode { coach, chef }

/// AI Daily Coach review + AI Chef pantry recipes (Gemini via Firebase AI).
class CoachTab extends ConsumerStatefulWidget {
  const CoachTab({super.key});

  @override
  ConsumerState<CoachTab> createState() => _CoachTabState();
}

class _CoachTabState extends ConsumerState<CoachTab> {
  var _mode = _Mode.coach;

  CoachReview? _review;
  var _coachLoading = false;
  String? _coachError;

  final _ingredients = TextEditingController();
  List<Recipe>? _recipes;
  var _chefLoading = false;
  String? _chefError;
  final _logged = <int>{};

  @override
  void initState() {
    super.initState();
    _ingredients.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ingredients.dispose();
    super.dispose();
  }

  String get _lang => ref.read(settingsProvider).language;

  Future<void> _askCoach() async {
    final t = AppLocalizations.of(context);
    final s = ref.read(appProvider);
    setState(() {
      _coachLoading = true;
      _coachError = null;
      _review = null;
    });
    try {
      final review = await ref
          .read(aiServiceProvider)
          .coachReview(
            entries: s.entries.where((e) => e.date == s.currentDate).toList(),
            goal: s.goal,
            date: s.currentDate,
            prefs: AiPrefs.fromProfile(s.profile),
            lang: _lang,
          );
      if (mounted) setState(() => _review = review);
    } catch (e) {
      if (mounted) setState(() => _coachError = aiErrorText(t, e, t.coachErrCoach));
    } finally {
      if (mounted) setState(() => _coachLoading = false);
    }
  }

  Future<void> _generateRecipes() async {
    final text = _ingredients.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context);
    setState(() {
      _chefLoading = true;
      _chefError = null;
      _recipes = null;
      _logged.clear();
    });
    try {
      final recipes = await ref
          .read(aiServiceProvider)
          .generateRecipes(text, AiPrefs.fromProfile(ref.read(appProvider).profile), _lang);
      if (mounted) setState(() => _recipes = recipes);
    } catch (e) {
      if (mounted) setState(() => _chefError = aiErrorText(t, e, t.coachErrRecipesGeneric));
    } finally {
      if (mounted) setState(() => _chefLoading = false);
    }
  }

  Future<void> _logRecipe(Recipe r, int index) async {
    setState(() => _logged.add(index));
    final ok = await ref
        .read(appProvider.notifier)
        .addEntry(
          NewEntry(
            date: ref.read(appProvider).currentDate,
            type: EntryType.meal,
            name: 'AI Chef: ${r.name}',
            calories: r.calories,
            protein: r.protein.roundToDouble(),
            carbs: r.carbs.roundToDouble(),
            fat: r.fat.roundToDouble(),
            quantity: 1, // 1 serving
          ),
        );
    if (!ok && mounted) setState(() => _logged.remove(index));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NfSegmented<_Mode>(
          filled: true,
          selected: _mode,
          onChanged: (m) => setState(() => _mode = m),
          options: [
            SegmentOption(_Mode.coach, t.coachDailyCoachTab, LucideIcons.activity),
            SegmentOption(_Mode.chef, t.coachChefTab, LucideIcons.utensils),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _mode == _Mode.coach
              ? KeyedSubtree(key: const ValueKey('coach'), child: _coachPanel(t))
              : KeyedSubtree(key: const ValueKey('chef'), child: _chefPanel(t)),
        ),
      ],
    );
  }

  Widget _intro({required IconData icon, required Color color, required String title, required String desc}) {
    final c = context.nf;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: icon, color: color, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ts(14, weight: w700, color: c.text),
              ),
              const SizedBox(height: 2),
              Text(desc, style: ts(11, color: c.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coachPanel(AppLocalizations t) {
    final c = context.nf;
    final r = _review;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: spaced([
        NfCard(
          padding: const EdgeInsets.all(16),
          radius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _intro(icon: LucideIcons.sparkles, color: c.accent, title: t.coachReviewTitle, desc: t.coachReviewDesc),
              const SizedBox(height: 16),
              NfButton(
                expand: true,
                gradient: true,
                loading: _coachLoading,
                icon: LucideIcons.sparkles,
                label: _coachLoading ? t.coachAnalyzing : t.coachRunReview,
                onPressed: _coachLoading ? null : _askCoach,
              ),
            ],
          ),
        ),
        if (_coachError != null) MessageBox(_coachError!),
        if (r != null) ...[
          _GradeCard(review: r),
          NfCard(
            padding: const EdgeInsets.all(16),
            radius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(c, LucideIcons.activity, t.coachDietitianSummary),
                const SizedBox(height: 8),
                Text(r.summary, style: ts(12, color: c.textBody, height: 1.6)),
              ],
            ),
          ),
          NfCard(
            padding: const EdgeInsets.all(16),
            radius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(c, LucideIcons.sparkles, t.coachRecommendations),
                const SizedBox(height: 12),
                ...spaced([
                  for (var i = 0; i < r.suggestions.length; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: NfColors.indigo.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: ts(10, weight: w700, color: c.accent),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r.suggestions[i],
                            style: ts(12, color: c.isLight ? c.textBody : const Color(0xFFCBD5E1), height: 1.6),
                          ),
                        ),
                      ],
                    ),
                ], 10),
              ],
            ),
          ),
        ],
      ], 16),
    );
  }

  Widget _label(NfColors c, IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: c.accent),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text.toUpperCase(),
          style: ts(12, weight: w700, color: c.accent, letterSpacing: 0.8),
        ),
      ),
    ],
  );

  Widget _chefPanel(AppLocalizations t) {
    final c = context.nf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: spaced([
        NfCard(
          padding: const EdgeInsets.all(16),
          radius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _intro(
                icon: LucideIcons.utensils,
                color: c.emeraldText,
                title: t.coachPantryTitle,
                desc: t.coachPantryDesc,
              ),
              const SizedBox(height: 12),
              NfTextField(
                controller: _ingredients,
                hint: t.coachPantryPlaceholder,
                fontSize: 12,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _generateRecipes(),
              ),
              const SizedBox(height: 12),
              NfButton(
                expand: true,
                gradient: true,
                variant: NfButtonVariant.emerald,
                loading: _chefLoading,
                icon: LucideIcons.sparkles,
                label: _chefLoading ? t.coachCookingRecipes : t.coachFormulate,
                onPressed: _chefLoading || _ingredients.text.trim().isEmpty ? null : _generateRecipes,
              ),
            ],
          ),
        ),
        if (_chefError != null) MessageBox(_chefError!),
        if (_recipes != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              t.coachMatchedOptions.toUpperCase(),
              style: ts(10, weight: w700, mono: true, color: c.textSecondary, letterSpacing: 1.5),
            ),
          ),
          for (var i = 0; i < _recipes!.length; i++) _recipeCard(t, _recipes![i], i),
        ],
      ], 16),
    );
  }

  Widget _recipeCard(AppLocalizations t, Recipe r, int index) {
    final c = context.nf;
    final logged = _logged.contains(index);
    Widget macro(String label, String value, Color color) => Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: ts(9, mono: true, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: ts(12, weight: w700, color: color == c.textSecondary ? c.text : color),
          ),
        ],
      ),
    );
    return NfCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
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
                    Text(
                      r.name,
                      style: ts(13, weight: w700, color: c.text, height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏱️ ${t.coachMins('${r.prepTime}')}    💪 ${r.difficulty}',
                      style: ts(10, mono: true, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NfButton(
                small: true,
                variant: logged ? NfButtonVariant.ghost : NfButtonVariant.primary,
                icon: logged ? LucideIcons.check : LucideIcons.plus,
                label: logged ? t.coachLogged : t.coachLogMeal,
                onPressed: logged ? null : () => _logRecipe(r, index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NfInset(
            padding: const EdgeInsets.all(8),
            radius: 12,
            child: Row(
              children: [
                macro(t.coachCalories, '${fmtNum(r.calories)} kcal', c.textSecondary),
                macro(t.coachProtein, '${r.protein.round()}g', NfColors.rose),
                macro(t.coachCarbs, '${r.carbs.round()}g', NfColors.amber),
                macro(t.coachFat, '${r.fat.round()}g', NfColors.emerald),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(r.summary, style: ts(11, color: c.textSecondary, height: 1.5)),
          const SizedBox(height: 10),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 10),
          Text(
            t.coachInstructions.toUpperCase(),
            style: ts(10, weight: w700, color: c.accent, letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: NfColors.indigoLight.withValues(alpha: 0.3))),
            ),
            child: Text(
              r.instructions,
              style: ts(11, color: c.isLight ? c.textBody : const Color(0xFFCBD5E1), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.review});
  final CoachReview review;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final g = review.grade.trim().toUpperCase();
    final (Color tint, Color fg) = g.startsWith('A')
        ? (NfColors.emerald, c.emeraldText)
        : g.startsWith('B')
        ? (NfColors.indigo, c.accent)
        : g.startsWith('C')
        ? (NfColors.amber, c.amberText)
        : (NfColors.rose, c.roseText);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.isLight ? fg : tint.withValues(alpha: 0.3), width: c.isLight ? 2 : 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.2), tint.withValues(alpha: 0.1)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: c.isLight ? 0.05 : 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.coachGrade.toUpperCase(),
                  style: ts(9, weight: w700, mono: true, color: c.textSecondary, letterSpacing: 1.5),
                ),
                Text(
                  review.grade,
                  style: ts(22, weight: w900, color: fg, height: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.award, size: 16, color: fg),
                    const SizedBox(width: 4),
                    Text(
                      t.coachCoachRating.toUpperCase(),
                      style: ts(12, weight: w700, color: fg, letterSpacing: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(review.streakMessage, style: ts(11, color: fg.withValues(alpha: 0.9), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
