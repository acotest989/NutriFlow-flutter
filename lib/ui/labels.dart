import '../l10n/app_localizations.dart';
import '../models/profile.dart';

// Localized labels for the canonical (English, stored) profile values.

String goalLabel(AppLocalizations t, GoalType g) => switch (g) {
  GoalType.lose => t.onboardingGoalsLoseLabel,
  GoalType.maintain => t.onboardingGoalsMaintainLabel,
  GoalType.gain => t.onboardingGoalsGainLabel,
  GoalType.buildMuscle => t.onboardingGoalsBuildMuscleLabel,
};

String goalHint(AppLocalizations t, GoalType g) => switch (g) {
  GoalType.lose => t.onboardingGoalsLoseHint,
  GoalType.maintain => t.onboardingGoalsMaintainHint,
  GoalType.gain => t.onboardingGoalsGainHint,
  GoalType.buildMuscle => t.onboardingGoalsBuildMuscleHint,
};

String sexLabel(AppLocalizations t, Sex s) => switch (s) {
  Sex.male => t.onboardingSexesMale,
  Sex.female => t.onboardingSexesFemale,
  Sex.other => t.onboardingSexesOther,
};

String activityLabel(AppLocalizations t, ActivityLevel a) => switch (a) {
  ActivityLevel.sedentary => t.onboardingActivitiesSedentaryLabel,
  ActivityLevel.light => t.onboardingActivitiesLightLabel,
  ActivityLevel.moderate => t.onboardingActivitiesModerateLabel,
  ActivityLevel.very => t.onboardingActivitiesVeryLabel,
  ActivityLevel.extra => t.onboardingActivitiesExtraLabel,
};

String activityHint(AppLocalizations t, ActivityLevel a) => switch (a) {
  ActivityLevel.sedentary => t.onboardingActivitiesSedentaryHint,
  ActivityLevel.light => t.onboardingActivitiesLightHint,
  ActivityLevel.moderate => t.onboardingActivitiesModerateHint,
  ActivityLevel.very => t.onboardingActivitiesVeryHint,
  ActivityLevel.extra => t.onboardingActivitiesExtraHint,
};

String dietLabel(AppLocalizations t, DietPreference d) => switch (d) {
  DietPreference.none => t.onboardingDietsNone,
  DietPreference.highProtein => t.onboardingDietsHighProtein,
  DietPreference.lowCarb => t.onboardingDietsLowCarb,
  DietPreference.keto => t.onboardingDietsKeto,
  DietPreference.vegetarian => t.onboardingDietsVegetarian,
  DietPreference.vegan => t.onboardingDietsVegan,
  DietPreference.mediterranean => t.onboardingDietsMediterranean,
  DietPreference.paleo => t.onboardingDietsPaleo,
};

String restrictionLabel(AppLocalizations t, String r) => switch (r) {
  'Gluten' => t.onboardingRestrictionsGluten,
  'Dairy' => t.onboardingRestrictionsDairy,
  'Nuts' => t.onboardingRestrictionsNuts,
  'Shellfish' => t.onboardingRestrictionsShellfish,
  'Eggs' => t.onboardingRestrictionsEggs,
  'Soy' => t.onboardingRestrictionsSoy,
  'Pork' => t.onboardingRestrictionsPork,
  _ => r,
};

String workoutLabel(AppLocalizations t, String w) => switch (w) {
  'Strength' => t.onboardingWorkoutsStrength,
  'Cardio' => t.onboardingWorkoutsCardio,
  'HIIT' => t.onboardingWorkoutsHIIT,
  'Running' => t.onboardingWorkoutsRunning,
  'Cycling' => t.onboardingWorkoutsCycling,
  'Yoga' => t.onboardingWorkoutsYoga,
  'Swimming' => t.onboardingWorkoutsSwimming,
  'Walking' => t.onboardingWorkoutsWalking,
  _ => w,
};

(String label, String desc) badgeText(AppLocalizations t, String id) => switch (id) {
  'start' => (t.chartsBadgesStartLabel, t.chartsBadgesStartDesc),
  'streak3' => (t.chartsBadgesStreak3Label, t.chartsBadgesStreak3Desc),
  'streak7' => (t.chartsBadgesStreak7Label, t.chartsBadgesStreak7Desc),
  'streak14' => (t.chartsBadgesStreak14Label, t.chartsBadgesStreak14Desc),
  'streak30' => (t.chartsBadgesStreak30Label, t.chartsBadgesStreak30Desc),
  'hydrated' => (t.chartsBadgesHydratedLabel, t.chartsBadgesHydratedDesc),
  _ => (t.chartsBadgesCenturyLabel, t.chartsBadgesCenturyDesc),
};
