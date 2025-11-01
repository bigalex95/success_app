import '../../../core/config/app_config.dart';
import '../../../core/database/database_helper_supabase.dart';
import '../../../core/database/models/habit_model.dart';
import '../../../core/database/models/progress_model.dart';

class HabitRepository {
  final DatabaseHelperSupabase _dbHelper = DatabaseHelperSupabase.instance;

  // Habit CRUD operations
  Future<int> createHabit(HabitModel habit) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.createHabit(habit);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<List<HabitModel>> getAllHabits() async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.getAllHabits();
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<HabitModel?> getHabitById(int id) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.getHabitById(id);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<int> updateHabit(HabitModel habit) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.updateHabit(habit);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<int> deleteHabit(int id) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.deleteHabit(id);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  // Progress operations
  Future<int> markProgress(ProgressModel progress) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.markProgress(progress);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<ProgressModel?> getProgressForDate(int habitId, DateTime date) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.getProgressForDate(habitId, date);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  Future<List<ProgressModel>> getProgressForHabit(int habitId, {int? limit}) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.getProgressForHabit(habitId, limit: limit);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  // Calculate streak for a habit
  Future<int> calculateStreak(int habitId) async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.calculateStreak(habitId);
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  // Get today's progress for all habits
  Future<Map<int, bool>> getTodayProgress() async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.getTodayProgress();
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStats() async {
    if (AppConfig.useSupabase) {
      return await _dbHelper.getCompletionStats();
    } else {
      throw UnimplementedError('SQLite support is deprecated. Please use Supabase.');
    }
  }
}
