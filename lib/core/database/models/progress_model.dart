class ProgressModel {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool completed;
  final String? notes;

  ProgressModel({
    this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'completed': completed ? 1 : 0, // Use 1/0 for compatibility
      'notes': notes,
    };
  }

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    // Handle both int (0/1) and bool for completed field
    final completedValue = map['completed'];
    final bool isCompleted = completedValue is bool 
        ? completedValue 
        : (completedValue is int ? completedValue == 1 : false);
    
    return ProgressModel(
      id: map['id'] is int ? map['id'] : (map['id'] != null ? int.parse(map['id'].toString()) : null),
      habitId: map['habit_id'] is int ? map['habit_id'] : int.parse(map['habit_id'].toString()),
      date: map['date'] is DateTime 
          ? map['date'] as DateTime
          : DateTime.parse(map['date'] as String),
      completed: isCompleted,
      notes: map['notes'] as String?,
    );
  }

  ProgressModel copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? completed,
    String? notes,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }
}

