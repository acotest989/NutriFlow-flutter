/// Daily calorie + macro targets (a row in the Supabase `goals` table).
class Goal {
  const Goal({required this.calories, required this.protein, required this.carbs, required this.fat});

  final double calories;
  final double protein; // g
  final double carbs; // g
  final double fat; // g

  static const defaults = Goal(calories: 2000, protein: 130, carbs: 220, fat: 65);

  factory Goal.fromRow(Map<String, dynamic> r) =>
      Goal(calories: _num(r['calories']), protein: _num(r['protein']), carbs: _num(r['carbs']), fat: _num(r['fat']));

  Map<String, dynamic> toRow() => {'calories': calories, 'protein': protein, 'carbs': carbs, 'fat': fat};

  @override
  bool operator ==(Object other) =>
      other is Goal &&
      other.calories == calories &&
      other.protein == protein &&
      other.carbs == carbs &&
      other.fat == fat;

  @override
  int get hashCode => Object.hash(calories, protein, carbs, fat);
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
