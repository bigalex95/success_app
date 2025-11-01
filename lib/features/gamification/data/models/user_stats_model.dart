class UserStatsModel {
  final int totalPoints;
  final int level;
  final int totalHabits;
  final int completedToday;
  final int longestStreak;
  final Map<int, int> habitStreaks; // habit_id -> streak

  UserStatsModel({
    required this.totalPoints,
    required this.level,
    required this.totalHabits,
    required this.completedToday,
    required this.longestStreak,
    required this.habitStreaks,
  });

  // Calculate level from points (e.g., 100 points per level)
  static int calculateLevel(int points) {
    return (points / 100).floor() + 1;
  }

  // Calculate points needed for next level
  int get pointsToNextLevel {
    final pointsForCurrentLevel = (level - 1) * 100;
    return (level * 100) - (totalPoints - pointsForCurrentLevel);
  }
}

