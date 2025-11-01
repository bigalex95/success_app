import '../../habits/data/habit_repository.dart';
import '../../gamification/data/gamification_repository.dart';
import 'providers/ollama_provider.dart';
import 'providers/api_provider.dart';

abstract class SLMService {
  Future<String> generateResponse(String userMessage, Map<String, dynamic> context);
  
  static SLMService createService(String providerType) {
    switch (providerType) {
      case 'ollama':
        return OllamaProvider();
      case 'api':
        return APIModelProvider();
      default:
        return OllamaProvider(); // Default to Ollama
    }
  }
}

class SLMContextBuilder {
  final HabitRepository _habitRepository = HabitRepository();
  final GamificationRepository _gamificationRepository = GamificationRepository();

  Future<Map<String, dynamic>> buildContext() async {
    final habits = await _habitRepository.getAllHabits();
    final stats = await _habitRepository.getCompletionStats();
    final userStats = await _gamificationRepository.getUserStats();
    final todayProgress = await _habitRepository.getTodayProgress();

    // Build habit summaries
    final habitSummaries = <Map<String, dynamic>>[];
    for (var habit in habits) {
      final streak = await _habitRepository.calculateStreak(habit.id!);
      final isCompletedToday = todayProgress[habit.id] ?? false;
      
      habitSummaries.add({
        'id': habit.id,
        'name': habit.name,
        'description': habit.description,
        'streak': streak,
        'completedToday': isCompletedToday,
      });
    }

    return {
      'habits': habitSummaries,
      'stats': {
        'totalHabits': stats['totalHabits'],
        'completedToday': stats['completedToday'],
        'completionRate': stats['completionRate'],
        'totalPoints': userStats.totalPoints,
        'level': userStats.level,
        'longestStreak': userStats.longestStreak,
      },
      'date': DateTime.now().toIso8601String(),
    };
  }

  String buildPrompt(String userMessage, Map<String, dynamic> context) {
    final habitsList = context['habits'] as List;
    final stats = context['stats'] as Map<String, dynamic>;
    
    final habitsText = habitsList.map((h) {
      return '- ${h['name']}: ${h['description'] ?? 'No description'} (Streak: ${h['streak']} days, Today: ${h['completedToday'] ? '✓' : '✗'})';
    }).join('\n');

    return '''You are a helpful habit tracking assistant. The user is working on building and maintaining good habits.

User's Current Status:
- Total Habits: ${stats['totalHabits']}
- Completed Today: ${stats['completedToday']}
- Completion Rate: ${(stats['completionRate'] * 100).toStringAsFixed(1)}%
- Level: ${stats['level']}
- Total Points: ${stats['totalPoints']}
- Longest Streak: ${stats['longestStreak']} days

Current Habits:
$habitsText

User's message: $userMessage

Provide helpful, encouraging, and actionable advice. Keep responses concise but meaningful. Focus on:
1. Understanding their habit goals
2. Offering practical tips for consistency
3. Encouraging them when they're on track
4. Helping them get back on track if they've missed days

Response:''';
  }
}

