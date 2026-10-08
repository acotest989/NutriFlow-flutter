import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow/core/goal_calc.dart';
import 'package:nutriflow/models/goal.dart';
import 'package:nutriflow/models/profile.dart';

OnboardingData make({
  GoalType goalType = GoalType.maintain,
  Sex sex = Sex.male,
  double age = 30,
  double heightCm = 180,
  double weightKg = 80,
  ActivityLevel activity = ActivityLevel.moderate,
  DietPreference diet = DietPreference.none,
}) => OnboardingData(
  goalType: goalType,
  sex: sex,
  age: age,
  heightCm: heightCm,
  weightKg: weightKg,
  targetWeightKg: null,
  activity: activity,
  diet: diet,
  restrictions: const [],
  workouts: const [],
  units: Units.metric,
);

void main() {
  group('unit conversions', () {
    test('round-trips kg <-> lb', () {
      expect(lbToKg(0), 0);
      expect(kgToLb(lbToKg(160)), closeTo(160, 1e-6));
      expect(lbToKg(kgToLb(72)), closeTo(72, 1e-6));
    });

    test('round-trips cm <-> in', () {
      expect(inToCm(10), closeTo(25.4, 1e-6));
      expect(cmToIn(inToCm(69)), closeTo(69, 1e-6));
    });

    test('splits cm into ft + in (matches the onboarding placeholders)', () {
      expect(cmToFtIn(175), (ft: 5, inches: 9));
      expect(cmToFtIn(180), (ft: 5, inches: 11));
      expect(cmToFtIn(152), (ft: 5, inches: 0));
      expect(ftInToCm(5, 9), closeTo(175.26, 1e-6));
    });
  });

  group('computeGoal', () {
    test('computes a known maintain target exactly (same as the web app)', () {
      expect(computeGoal(make()), const Goal(calories: 2760, protein: 130, carbs: 375, fat: 85));
    });

    test('applies the female calorie floor (1200)', () {
      final g = computeGoal(
        make(
          sex: Sex.female,
          weightKg: 45,
          heightCm: 150,
          age: 60,
          activity: ActivityLevel.sedentary,
          goalType: GoalType.lose,
        ),
      );
      expect(g.calories, 1200);
    });

    test('applies the male calorie floor (1500)', () {
      final g = computeGoal(
        make(weightKg: 40, heightCm: 150, age: 80, activity: ActivityLevel.sedentary, goalType: GoalType.lose),
      );
      expect(g.calories, 1500);
    });

    test('scales protein with bodyweight', () {
      expect(computeGoal(make(weightKg: 100)).protein, greaterThan(computeGoal(make(weightKg: 60)).protein));
    });

    test('high-protein diet raises the protein target', () {
      expect(computeGoal(make(diet: DietPreference.highProtein)).protein, greaterThan(computeGoal(make()).protein));
    });

    test('keto and low-carb shift macros toward fat', () {
      final none = computeGoal(make(goalType: GoalType.buildMuscle));
      final keto = computeGoal(make(goalType: GoalType.buildMuscle, diet: DietPreference.keto));
      final lowCarb = computeGoal(make(goalType: GoalType.buildMuscle, diet: DietPreference.lowCarb));
      expect(keto.fat, greaterThan(none.fat));
      expect(keto.carbs, lessThan(none.carbs));
      expect(lowCarb.fat, greaterThan(none.fat));
      expect(lowCarb.carbs, lessThan(none.carbs));
    });

    test('orders calories by sex constant (male > other > female) for the same body', () {
      double cal(Sex sex) =>
          computeGoal(make(weightKg: 90, heightCm: 185, age: 25, activity: ActivityLevel.very, sex: sex)).calories;
      expect(cal(Sex.male), greaterThan(cal(Sex.other)));
      expect(cal(Sex.other), greaterThan(cal(Sex.female)));
    });

    test('never returns negative macros and respects the calorie floor', () {
      for (final goalType in GoalType.values) {
        for (final diet in [
          DietPreference.none,
          DietPreference.keto,
          DietPreference.lowCarb,
          DietPreference.highProtein,
        ]) {
          final g = computeGoal(make(goalType: goalType, diet: diet));
          expect(g.calories, greaterThanOrEqualTo(1500));
          expect(g.protein, greaterThanOrEqualTo(0));
          expect(g.carbs, greaterThanOrEqualTo(0));
          expect(g.fat, greaterThanOrEqualTo(0));
        }
      }
    });
  });
}
