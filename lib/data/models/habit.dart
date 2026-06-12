class Habit {
  final int? id;
  final String name;
  final List<int> targetDaysOfWeek; // 0=Mon..6=Sun, empty = every day
  final int timesPerDay;
  final bool strictMode;
  final bool isArchived;
  final DateTime createdAt;

  const Habit({
    this.id,
    required this.name,
    required this.targetDaysOfWeek,
    required this.timesPerDay,
    required this.strictMode,
    required this.isArchived,
    required this.createdAt,
  });

  Habit copyWith({
    int? id,
    String? name,
    List<int>? targetDaysOfWeek,
    int? timesPerDay,
    bool? strictMode,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      targetDaysOfWeek: targetDaysOfWeek ?? this.targetDaysOfWeek,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      strictMode: strictMode ?? this.strictMode,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'targetDaysOfWeek': targetDaysOfWeek.join(','),
      'timesPerDay': timesPerDay,
      'strictMode': strictMode ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetDaysOfWeek: (map['targetDaysOfWeek'] as String).isEmpty
          ? []
          : (map['targetDaysOfWeek'] as String)
              .split(',')
              .map(int.parse)
              .toList(),
      timesPerDay: map['timesPerDay'] as int,
      strictMode: (map['strictMode'] as int) == 1,
      isArchived: (map['isArchived'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Returns true if this habit is scheduled for the given date.
  bool isScheduledFor(DateTime date) {
    if (targetDaysOfWeek.isEmpty) return true;
    final weekday = date.weekday - 1; // 0=Mon..6=Sun
    return targetDaysOfWeek.contains(weekday);
  }
}
