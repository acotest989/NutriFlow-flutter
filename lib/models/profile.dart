// Onboarding / personalization types. Wire values are the canonical English
// strings stored in Supabase (shared with the web app) — never translate them.

enum GoalType {
  lose('lose'),
  maintain('maintain'),
  gain('gain'),
  buildMuscle('build_muscle');

  const GoalType(this.wire);
  final String wire;
  static GoalType? parse(Object? v) => _byWire(values, v, (e) => e.wire);
}

enum Sex {
  male('male'),
  female('female'),
  other('other');

  const Sex(this.wire);
  final String wire;
  static Sex? parse(Object? v) => _byWire(values, v, (e) => e.wire);
}

enum ActivityLevel {
  sedentary('sedentary'),
  light('light'),
  moderate('moderate'),
  very('very'),
  extra('extra');

  const ActivityLevel(this.wire);
  final String wire;
  static ActivityLevel? parse(Object? v) => _byWire(values, v, (e) => e.wire);
}

enum DietPreference {
  none('none'),
  highProtein('high_protein'),
  lowCarb('low_carb'),
  keto('keto'),
  vegetarian('vegetarian'),
  vegan('vegan'),
  mediterranean('mediterranean'),
  paleo('paleo');

  const DietPreference(this.wire);
  final String wire;
  static DietPreference? parse(Object? v) => _byWire(values, v, (e) => e.wire);
}

enum Units {
  metric('metric'),
  imperial('imperial');

  const Units(this.wire);
  final String wire;
  static Units? parse(Object? v) => _byWire(values, v, (e) => e.wire);
}

const restrictionOptions = ['Gluten', 'Dairy', 'Nuts', 'Shellfish', 'Eggs', 'Soy', 'Pork'];
const workoutOptions = ['Strength', 'Cardio', 'HIIT', 'Running', 'Cycling', 'Yoga', 'Swimming', 'Walking'];

/// Canonical onboarding answers. Body measurements are always metric (cm / kg);
/// [units] only controls how they're displayed and entered.
class OnboardingData {
  const OnboardingData({
    required this.goalType,
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    required this.activity,
    required this.diet,
    required this.restrictions,
    required this.workouts,
    required this.units,
  });

  final GoalType goalType;
  final Sex sex;
  final double age;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final ActivityLevel activity;
  final DietPreference diet;
  final List<String> restrictions;
  final List<String> workouts;
  final Units units;

  /// Columns of the `profiles` row (minus user_id / flags).
  Map<String, dynamic> toRow() => {
    'goal_type': goalType.wire,
    'sex': sex.wire,
    'age': age.round(),
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'target_weight_kg': targetWeightKg,
    'activity': activity.wire,
    'diet': diet.wire,
    'restrictions': restrictions,
    'workouts': workouts,
    'units': units.wire,
  };

  factory OnboardingData.fromRow(Map<String, dynamic> r) => OnboardingData(
    goalType: GoalType.parse(r['goal_type']) ?? GoalType.maintain,
    sex: Sex.parse(r['sex']) ?? Sex.other,
    age: _num(r['age']),
    heightCm: _num(r['height_cm']),
    weightKg: _num(r['weight_kg']),
    targetWeightKg: r['target_weight_kg'] == null ? null : _num(r['target_weight_kg']),
    activity: ActivityLevel.parse(r['activity']) ?? ActivityLevel.moderate,
    diet: DietPreference.parse(r['diet']) ?? DietPreference.none,
    restrictions: _strings(r['restrictions']),
    workouts: _strings(r['workouts']),
    units: Units.parse(r['units']) ?? Units.metric,
  );
}

/// A row in the Supabase `profiles` table.
class Profile extends OnboardingData {
  const Profile({
    required super.goalType,
    required super.sex,
    required super.age,
    required super.heightCm,
    required super.weightKg,
    required super.targetWeightKg,
    required super.activity,
    required super.diet,
    required super.restrictions,
    required super.workouts,
    required super.units,
    required this.hasOnboarded,
    this.language,
  });

  final bool hasOnboarded;
  final String? language; // en / sr / hr / bs — synced across devices

  factory Profile.fromRow(Map<String, dynamic> r) {
    final d = OnboardingData.fromRow(r);
    return Profile.from(d, hasOnboarded: r['has_onboarded'] == true, language: r['language'] as String?);
  }

  factory Profile.from(OnboardingData d, {required bool hasOnboarded, String? language}) => Profile(
    goalType: d.goalType,
    sex: d.sex,
    age: d.age,
    heightCm: d.heightCm,
    weightKg: d.weightKg,
    targetWeightKg: d.targetWeightKg,
    activity: d.activity,
    diet: d.diet,
    restrictions: d.restrictions,
    workouts: d.workouts,
    units: d.units,
    hasOnboarded: hasOnboarded,
    language: language,
  );

  Profile withLanguage(String code) => Profile.from(this, hasOnboarded: hasOnboarded, language: code);

  @override
  Map<String, dynamic> toRow() => {...super.toRow(), 'has_onboarded': hasOnboarded, 'language': language};
}

T? _byWire<T>(List<T> values, Object? v, String Function(T) wire) {
  for (final e in values) {
    if (wire(e) == v) return e;
  }
  return null;
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

List<String> _strings(Object? v) => v is List ? v.map((e) => '$e').toList() : const [];
