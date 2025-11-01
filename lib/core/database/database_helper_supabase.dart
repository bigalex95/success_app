import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'models/habit_model.dart';
import 'models/progress_model.dart';

/// Database helper using Supabase (works on all platforms)
class DatabaseHelperSupabase {
  static final DatabaseHelperSupabase instance = DatabaseHelperSupabase._init();

  DatabaseHelperSupabase._init();

  SupabaseClient get _client => SupabaseService.client;

  // ============ Habits Operations ============

  Future<int> createHabit(HabitModel habit) async {
    final response =
        await _client.from('habits').insert(habit.toMap()).select().single();
    return response['id'] as int;
  }

  Future<List<HabitModel>> getAllHabits() async {
    final response = await _client
        .from('habits')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => HabitModel.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<HabitModel?> getHabitById(int id) async {
    final response =
        await _client.from('habits').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return HabitModel.fromMap(Map<String, dynamic>.from(response));
  }

  Future<int> updateHabit(HabitModel habit) async {
    await _client
        .from('habits')
        .update(habit.copyWith(updatedAt: DateTime.now()).toMap())
        .eq('id', habit.id!);
    return habit.id!;
  }

  Future<int> deleteHabit(int id) async {
    await _client.from('habits').delete().eq('id', id);
    return id;
  }

  // ============ Progress Operations ============

  Future<int> markProgress(ProgressModel progress) async {
    final dateStr = progress.date.toIso8601String().split('T')[0];

    // Check if progress already exists
    final existing = await _client
        .from('progress')
        .select()
        .eq('habit_id', progress.habitId)
        .eq('date', dateStr)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      final response = await _client
          .from('progress')
          .update(progress.toMap())
          .eq('habit_id', progress.habitId)
          .eq('date', dateStr)
          .select()
          .single();
      return response['id'] as int;
    } else {
      // Insert new
      final response = await _client
          .from('progress')
          .insert(progress.toMap())
          .select()
          .single();
      return response['id'] as int;
    }
  }

  Future<ProgressModel?> getProgressForDate(int habitId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _client
        .from('progress')
        .select()
        .eq('habit_id', habitId)
        .eq('date', dateStr)
        .maybeSingle();

    if (response == null) return null;
    return ProgressModel.fromMap(Map<String, dynamic>.from(response));
  }

  Future<List<ProgressModel>> getProgressForHabit(int habitId,
      {int? limit}) async {
    var query = _client
        .from('progress')
        .select()
        .eq('habit_id', habitId)
        .order('date', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return (response as List)
        .map((map) => ProgressModel.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<Map<int, bool>> getTodayProgress() async {
    final today = DateTime.now();
    final dateStr = today.toIso8601String().split('T')[0];

    final response = await _client
        .from('progress')
        .select()
        .eq('date', dateStr)
        .eq('completed', 1);

    final Map<int, bool> progress = {};
    for (var map in response as List) {
      progress[map['habit_id'] as int] = true;
    }
    return progress;
  }

  // Calculate streak for a habit
  Future<int> calculateStreak(int habitId) async {
    final today = DateTime.now();
    int streak = 0;
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    while (true) {
      final dateStr = currentDate.toIso8601String().split('T')[0];
      final response = await _client
          .from('progress')
          .select()
          .eq('habit_id', habitId)
          .eq('date', dateStr)
          .eq('completed', 1)
          .maybeSingle();

      if (response != null) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        // Allow one buffer day (yesterday might not be completed yet)
        if (streak == 0 && currentDate.day == today.day) {
          currentDate = currentDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return streak;
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStats() async {
    debugPrint('[ProgressDashboard] Fetching completion stats for today');
    final today = DateTime.now();
    final dateStr = today.toIso8601String().split('T')[0];

    // Total habits - get all and count
    final totalHabitsResponse = await _client.from('habits').select('id');
    final totalHabits = (totalHabitsResponse as List).length;

    // Completed today - get all and count unique habit_ids
    final completedResponse = await _client
        .from('progress')
        .select('habit_id')
        .eq('date', dateStr)
        .eq('completed', 1);

    // Get unique habit_ids
    final completedHabits = (completedResponse as List)
        .map((map) => map['habit_id'] as int)
        .toSet()
        .length;

    final completionRate =
        totalHabits > 0 ? (completedHabits / totalHabits) : 0.0;

    return {
      'totalHabits': totalHabits,
      'completedToday': completedHabits,
      'completionRate': completionRate,
    };
  }

  // Count progress entries (for gamification)
  Future<int> getCompletedProgressCount() async {
    final response =
        await _client.from('progress').select('id').eq('completed', 1);
    return (response as List).length;
  }
}
