import 'dart:math' as math;

import '../models/goal.dart';
import '../models/profile.dart';

// ---------- Unit conversions ----------
const kgPerLb = 0.45359237;
const cmPerIn = 2.54;

double lbToKg(double lb) => lb * kgPerLb;
double kgToLb(double kg) => kg / kgPerLb;
double inToCm(double inches) => inches * cmPerIn;
double cmToIn(double cm) => cm / cmPerIn;

/// Split a height in cm into feet + inches (for imperial display/entry).
({int ft, int inches}) cmToFtIn(double cm) {
  final totalIn = cmToIn(cm).round();
  return (ft: totalIn ~/ 12, inches: totalIn % 12);
}

double ftInToCm(double ft, double inches) => inToCm(ft * 12 + inches);

// ---------- Goal computation (Mifflin–St Jeor) ----------
const _activityFactors = {
  ActivityLevel.sedentary: 1.2,
  ActivityLevel.light: 1.375,
  ActivityLevel.moderate: 1.55,
  ActivityLevel.very: 1.725,
  ActivityLevel.extra: 1.9,
};

// kcal/day adjustment applied to TDEE for each goal.
const _goalDelta = {
  GoalType.lose: -0.2, // 20% deficit
  GoalType.maintain: 0.0,
  GoalType.gain: 0.12, // ~12% surplus
  GoalType.buildMuscle: 0.1, // lean bulk
};

// Protein target in g per kg bodyweight, by goal.
const _proteinPerKg = {
  GoalType.lose: 1.8, // preserve muscle in a deficit
  GoalType.maintain: 1.6,
  GoalType.gain: 1.8,
  GoalType.buildMuscle: 2.0,
};

/// Round to the nearest [step], halves away from zero like JS `Math.round` for
/// the positive values used here.
double _roundTo(double n, double step) => (n / step).roundToDouble() * step;

double _bmr(Sex sex, double kg, double cm, double age) {
  // Mifflin–St Jeor; "other" uses the average of the male/female constants.
  final base = 10 * kg + 6.25 * cm - 5 * age;
  final constant = switch (sex) {
    Sex.male => 5,
    Sex.female => -161,
    Sex.other => -78,
  };
  return base + constant;
}

/// Compute a personalized daily calorie + macro goal from onboarding answers.
/// Macro split adapts to the dietary preference (keto / low-carb /
/// high-protein); everything else uses a balanced split.
Goal computeGoal(OnboardingData d) {
  final tdee = _bmr(d.sex, d.weightKg, d.heightCm, d.age) * _activityFactors[d.activity]!;
  var calories = tdee * (1 + _goalDelta[d.goalType]!);
  // Safety floor so the target is never unhealthily low.
  calories = math.max(d.sex == Sex.female ? 1200 : 1500, calories);

  // Protein from bodyweight (capped so it never dominates very low-cal targets).
  var proteinPerKg = _proteinPerKg[d.goalType]!;
  if (d.diet == DietPreference.highProtein) proteinPerKg = math.max(proteinPerKg, 2.0);
  var protein = d.weightKg * proteinPerKg;

  // Fat as a share of calories, varied by diet.
  var fatPct = 0.27;
  if (d.diet == DietPreference.keto) {
    fatPct = 0.7;
  } else if (d.diet == DietPreference.lowCarb) {
    fatPct = 0.4;
  }
  var fat = (calories * fatPct) / 9;

  // Carbs take the remainder.
  var carbs = (calories - protein * 4 - fat * 9) / 4;

  // If carbs would go negative (e.g. keto + high protein), trim protein toward
  // the floor and recompute so macros stay consistent with the calorie target.
  final minCarbs = d.diet == DietPreference.keto ? 20.0 : 40.0;
  if (carbs < minCarbs) {
    carbs = minCarbs;
    final remaining = calories - carbs * 4;
    protein = math.max(d.weightKg * 1.6, (remaining * 0.5) / 4);
    fat = (calories - protein * 4 - carbs * 4) / 9;
  }

  return Goal(
    calories: _roundTo(calories, 10),
    protein: _roundTo(protein, 5),
    carbs: _roundTo(math.max(carbs, 0), 5),
    fat: _roundTo(math.max(fat, 0), 5),
  );
}
