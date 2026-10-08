import '../models/profile.dart';

/// Compact preferences sent to the AI prompts so coaching + recipes respect the
/// user's goal, diet, allergies, and workout preferences.
class AiPrefs {
  const AiPrefs({this.goalType, this.diet, this.restrictions = const [], this.workouts = const [], this.activity});

  final String? goalType;
  final String? diet;
  final List<String> restrictions;
  final List<String> workouts;
  final String? activity;

  /// Build from the profile, omitting empty/neutral values. Null when there's
  /// nothing useful to send.
  static AiPrefs? fromProfile(Profile? p) {
    if (p == null) return null;
    final prefs = AiPrefs(
      goalType: p.goalType.wire,
      diet: p.diet == DietPreference.none ? null : p.diet.wire,
      restrictions: p.restrictions,
      workouts: p.workouts,
      activity: p.activity.wire,
    );
    return prefs;
  }

  static const _goalText = {
    'lose': 'lose weight',
    'maintain': 'maintain weight',
    'gain': 'gain weight',
    'build_muscle': 'build muscle',
  };

  /// Prompt snippet the model can act on (same wording as the web server).
  String toPromptText() {
    final parts = <String>[
      if (goalType != null) 'their primary goal is to ${_goalText[goalType] ?? goalType}',
      if (diet != null) 'they follow a ${diet!.replaceAll('_', ' ')} diet',
      if (restrictions.isNotEmpty) 'they must avoid (allergies/restrictions): ${restrictions.join(', ')}',
      if (workouts.isNotEmpty) 'they prefer these workouts: ${workouts.join(', ')}',
      if (activity != null) 'activity level: $activity',
    ];
    return parts.isEmpty ? '' : ' User profile — ${parts.join('; ')}.';
  }
}
