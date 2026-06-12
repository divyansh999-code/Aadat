class HabitLog {
  final int? id;
  final int habitId;
  final DateTime date;
  final int completionCount;

  const HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    required this.completionCount,
  });

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    int? completionCount,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completionCount: completionCount ?? this.completionCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habitId': habitId,
      'date': _dateKey(date),
      'completionCount': completionCount,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int?,
      habitId: map['habitId'] as int,
      date: DateTime.parse(map['date'] as String),
      completionCount: map['completionCount'] as int,
    );
  }

  static String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
