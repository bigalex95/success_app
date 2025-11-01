class HabitModel {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitModel({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    // Handle different ID types (int, BigInt, or String from Supabase)
    int? id;
    if (map['id'] != null) {
      if (map['id'] is int) {
        id = map['id'] as int;
      } else {
        id = int.tryParse(map['id'].toString());
      }
    }
    
    // Handle DateTime from Supabase (might be String or DateTime)
    DateTime parseDateTime(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      throw FormatException('Invalid date format: $value');
    }
    
    return HabitModel(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: parseDateTime(map['created_at']),
      updatedAt: parseDateTime(map['updated_at']),
    );
  }

  HabitModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

