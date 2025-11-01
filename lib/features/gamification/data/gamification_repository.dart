import '../../../core/config/app_config.dart';
import '../../../core/database/database_helper_supabase.dart';
import '../../../features/habits/data/habit_repository.dart';
import 'models/user_stats_model.dart';
import 'models/achievement_model.dart';

class GamificationRepository {
  final DatabaseHelperSupabase _dbHelper = DatabaseHelperSupabase.instance;
  final HabitRepository _habitRepository = HabitRepository();

  // Points system
  static const int pointsPerCompletion = 10;
  static const int pointsPerStreakDay = 5;
  static const int pointsPerAchievement = 50;

  Future<int> getTotalPoints() async {
    if (AppConfig.useSupabase) {
      // Calculate total points from progress
      final completedCount = await _dbHelper.getCompletedProgressCount();

      // Calculate streak bonus points
      final habits = await _habitRepository.getAllHabits();
      int streakPoints = 0;
      for (var habit in habits) {
        final streak = await _habitRepository.calculateStreak(habit.id!);
        streakPoints += (streak - 1) * pointsPerStreakDay; // -1 because first day doesn't count as streak
        if (streakPoints < 0) streakPoints = 0;
      }

      final basePoints = completedCount * pointsPerCompletion;
      return basePoints + streakPoints;
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<UserStatsModel> getUserStats() async {
    final habits = await _habitRepository.getAllHabits();
    final todayProgress = await _habitRepository.getTodayProgress();
    final stats = await _habitRepository.getCompletionStats();

    final Map<int, int> habitStreaks = {};
    int longestStreak = 0;

    for (var habit in habits) {
      final streak = await _habitRepository.calculateStreak(habit.id!);
      habitStreaks[habit.id!] = streak;
      if (streak > longestStreak) {
        longestStreak = streak;
      }
    }

    final totalPoints = await getTotalPoints();
    final level = UserStatsModel.calculateLevel(totalPoints);

    return UserStatsModel(
      totalPoints: totalPoints,
      level: level,
      totalHabits: stats['totalHabits'] as int,
      completedToday: todayProgress.length,
      longestStreak: longestStreak,
      habitStreaks: habitStreaks,
    );
  }

  // Award points for completing a habit
  Future<void> awardCompletionPoints(int habitId) async {
    // Points are calculated on-the-fly, no need to store separately
    // This could be enhanced to store point transactions in the future
  }

  // Achievement system
  Future<List<AchievementModel>> getAllAchievements() async {
    // Define default achievements
    return [
      AchievementModel(
        id: 1,
        type: AchievementType.firstHabit,
        title: 'Getting Started',
        description: 'Create your first habit',
        icon: '🎯',
        unlocked: false,
      ),
      AchievementModel(
        id: 2,
        type: AchievementType.weekStreak,
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '🔥',
        unlocked: false,
      ),
      AchievementModel(
        id: 3,
        type: AchievementType.monthStreak,
        title: 'Month Master',
        description: 'Maintain a 30-day streak',
        icon: '⭐',
        unlocked: false,
      ),
      AchievementModel(
        id: 4,
        type: AchievementType.perfectWeek,
        title: 'Perfect Week',
        description: 'Complete all habits every day for a week',
        icon: '💯',
        unlocked: false,
      ),
      AchievementModel(
        id: 5,
        type: AchievementType.habitMaster,
        title: 'Habit Master',
        description: 'Create 10 habits',
        icon: '👑',
        unlocked: false,
      ),
    ];
  }

  Future<List<AchievementModel>> checkAndUnlockAchievements() async {
    final achievements = await getAllAchievements();
    final stats = await getUserStats();
    final updatedAchievements = <AchievementModel>[];

    for (var achievement in achievements) {
      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.firstHabit:
          shouldUnlock = stats.totalHabits >= 1;
          break;
        case AchievementType.weekStreak:
          shouldUnlock = stats.longestStreak >= 7;
          break;
        case AchievementType.monthStreak:
          shouldUnlock = stats.longestStreak >= 30;
          break;
        case AchievementType.perfectWeek:
          // Check if all habits completed for last 7 days
          shouldUnlock = await _checkPerfectWeek();
          break;
        case AchievementType.habitMaster:
          shouldUnlock = stats.totalHabits >= 10;
          break;
      }

      if (shouldUnlock && !achievement.unlocked) {
        updatedAchievements.add(achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        ));
      } else {
        updatedAchievements.add(achievement);
      }
    }

    return updatedAchievements;
  }

  Future<bool> _checkPerfectWeek() async {
    final habits = await _habitRepository.getAllHabits();
    if (habits.isEmpty) return false;

    final today = DateTime.now();
    
    // Check each of the last 7 days (including today)
    for (int i = 0; i < 7; i++) {
      final checkDate = today.subtract(Duration(days: i));
      
      // For each day, check if all habits were completed
      for (var habit in habits) {
        final progress = await _habitRepository.getProgressForDate(
          habit.id!,
          checkDate,
        );
        
        // If any habit wasn't completed on any day, it's not a perfect week
        if (progress == null || !progress.completed) {
          return false;
        }
      }
    }
    
    // All habits completed for all 7 days
    return true;
  }
}

extension AchievementModelExtension on AchievementModel {
  AchievementModel copyWith({
    int? id,
    AchievementType? type,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

