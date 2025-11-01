enum AchievementType {
  firstHabit,
  weekStreak,
  monthStreak,
  perfectWeek,
  habitMaster,
}

class AchievementModel {
  final int id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'] as int,
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      unlocked: (map['unlocked'] as int) == 1,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
    );
  }
}

