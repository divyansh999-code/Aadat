class HabitStack {
  final int? id;
  final String name;
  final List<int> habitIds; // ordered sequence
  final DateTime createdAt;

  const HabitStack({
    this.id,
    required this.name,
    required this.habitIds,
    required this.createdAt,
  });

  HabitStack copyWith({
    int? id,
    String? name,
    List<int>? habitIds,
    DateTime? createdAt,
  }) {
    return HabitStack(
      id: id ?? this.id,
      name: name ?? this.name,
      habitIds: habitIds ?? this.habitIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'habitIds': habitIds.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitStack.fromMap(Map<String, dynamic> map) {
    final habitIdsStr = map['habitIds'] as String;
    return HabitStack(
      id: map['id'] as int?,
      name: map['name'] as String,
      habitIds: habitIdsStr.isEmpty
          ? []
          : habitIdsStr.split(',').map(int.parse).toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
