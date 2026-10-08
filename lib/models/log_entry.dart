enum EntryType {
  meal,
  exercise;

  static EntryType parse(Object? v) => v == 'exercise' ? EntryType.exercise : EntryType.meal;
}

/// One logged meal or exercise (a row in the Supabase `entries` table).
/// Exercise calories are stored positive and subtracted when computing net.
class LogEntry {
  const LogEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.timestamp,
  });

  final String id;
  final String date; // YYYY-MM-DD (local calendar date)
  final EntryType type;
  final String name;
  final double calories;
  final double protein; // 0 for exercise
  final double carbs; // 0 for exercise
  final double fat; // 0 for exercise
  final double quantity; // grams of food, or minutes of exercise
  final String timestamp; // ISO created_at

  bool get isMeal => type == EntryType.meal;

  factory LogEntry.fromRow(Map<String, dynamic> r) => LogEntry(
    id: r['id'] as String,
    date: r['date'] as String,
    type: EntryType.parse(r['type']),
    name: r['name'] as String? ?? '',
    calories: _num(r['calories']),
    protein: _num(r['protein']),
    carbs: _num(r['carbs']),
    fat: _num(r['fat']),
    quantity: _num(r['quantity']),
    timestamp: r['created_at'] as String? ?? '',
  );

  /// Same keys as the DB row, so the local cache round-trips through [fromRow].
  Map<String, dynamic> toRow() => {
    'id': id,
    'date': date,
    'type': type.name,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'quantity': quantity,
    'created_at': timestamp,
  };
}

/// An entry about to be inserted (the DB assigns id + created_at).
class NewEntry {
  const NewEntry({
    required this.date,
    required this.type,
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.quantity,
  });

  final String date;
  final EntryType type;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity;

  Map<String, dynamic> toInsert(String userId) => {
    'user_id': userId,
    'date': date,
    'type': type.name,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'quantity': quantity,
  };
}

double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
