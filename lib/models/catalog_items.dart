/// A food with nutrition per serving (catalog item, online result or AI estimate).
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
  });

  final String id;
  final String name;
  final double calories;
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final double servingSize;
  final String servingUnit;

  factory FoodItem.fromJson(Map<String, dynamic> j, {String id = ''}) => FoodItem(
    id: (j['id'] as String?) ?? id,
    name: '${j['name'] ?? ''}'.trim(),
    calories: _num(j['calories']),
    protein: _num(j['protein']),
    carbs: _num(j['carbs']),
    fat: _num(j['fat']),
    servingSize: _num(j['servingSize']),
    servingUnit: '${j['servingUnit'] ?? 'g'}',
  );
}

/// A workout with an estimated burn rate.
class ExerciseItem {
  const ExerciseItem({required this.id, required this.name, required this.caloriesPerMinute});

  final String id;
  final String name;
  final double caloriesPerMinute;

  factory ExerciseItem.fromJson(Map<String, dynamic> j) =>
      ExerciseItem(id: j['id'] as String, name: j['name'] as String, caloriesPerMinute: _num(j['caloriesPerMinute']));

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'caloriesPerMinute': caloriesPerMinute};
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
