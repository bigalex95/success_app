import '../../habits/data/habit_repository.dart';
import '../../gamification/data/gamification_repository.dart';
import 'providers/ollama_provider.dart';
import 'providers/api_provider.dart';
import 'providers/gemini_provider.dart';

abstract class SLMService {
  Future<String> generateResponse(
      String userMessage, Map<String, dynamic> context);

  static SLMService createService(String providerType) {
    switch (providerType) {
      case 'ollama':
        return OllamaProvider();
      case 'gemini':
        return GeminiProvider();
      case 'api':
        return APIModelProvider();
      default:
        return OllamaProvider(); // Default to Ollama
    }
  }
}

class SLMContextBuilder {
  final HabitRepository _habitRepository = HabitRepository();
  final GamificationRepository _gamificationRepository =
      GamificationRepository();

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
    final habitsList =
        (context['habits'] is List) ? context['habits'] as List : [];
    final stats = (context['stats'] is Map<String, dynamic>)
        ? context['stats'] as Map<String, dynamic>
        : {};
    final chatHistory =
        (context['history'] is String) ? context['history'] as String : '';

    final habitsText = habitsList.isNotEmpty
        ? habitsList.map((h) {
            return '- ${h['name']}: ${h['description'] ?? 'No description'} (Streak: ${h['streak']} days, Today: ${h['completedToday'] ? '✓' : '✗'})';
          }).join('\n')
        : 'No habits found.';

    final historySection = chatHistory.isNotEmpty
        ? '''
RECENT CONVERSATION HISTORY:
$chatHistory

'''
        : '';

    return '''You are a helpful habit tracking assistant for an app called "Success". Help users build and maintain good habits.

===== USER'S CURRENT HABIT DATA =====
Total Habits: ${stats['totalHabits'] ?? 0}
Completed Today: ${stats['completedToday'] ?? 0}/${stats['totalHabits'] ?? 0}
Completion Rate: ${(stats['completionRate'] != null) ? (stats['completionRate'] * 100).toStringAsFixed(0) : '0'}%

${habitsList.isNotEmpty ? 'EXISTING HABITS:' : 'NO HABITS YET'}
$habitsText
=====================================

${historySection}USER'S QUESTION: "$userMessage"

INSTRUCTIONS - Choose the right response type:

1. GREETING (hi, hello, hey alone):
   Reply warmly and offer help. Example: "Hi! I'm your habit assistant. ${habitsList.isNotEmpty ? 'I see you have ${stats['totalHabits']} habits. Want to check on them or add more?' : 'Ready to start building some great habits?'}"

2. CREATE NEW HABITS (keywords: create, add, suggest, plan new habits + mentions activities):
   Output ONLY JSON, one per line. NO other text.
   {
     "habit_name": "Activity Name",
     "description": "Detailed description",
     "frequency": "daily"
   }

3. QUESTIONS ABOUT EXISTING HABITS (check, list, show, explain my habits):
   Look at the USER'S CURRENT HABIT DATA above and talk about THOSE specific habits.
   ${habitsList.isNotEmpty ? 'The user HAS ${stats['totalHabits']} habits listed above. Reference them specifically by name.' : 'The user has NO habits yet. Suggest creating some.'}

4. GENERAL ADVICE (tips, motivation, how to improve):
   Provide helpful advice. If they have existing habits, reference them specifically.

IMPORTANT: 
- ALWAYS check the "EXISTING HABITS" section before answering
- If user has habits, acknowledge them specifically by name
- Don't say "no habits" if habits are listed above

Your response:''';
  }

  String buildHabitPrompt(String userInput) {
    return "You are a habit assistant. Only suggest new habits when the user explicitly requests them. If the user input is unrelated, respond appropriately without suggesting habits. When suggesting habits, use the JSON format below and ensure they align with the user's goals, preferences, and context.\n\n"
            "Example format:\n" +
        "{\n" +
        "  \"habit_name\": \"Daily Reading\",\n" +
        "  \"description\": \"Spend 30 minutes reading books related to AI and tech stacks\",\n" +
        "  \"frequency\": \"daily\"\n" +
        "}\n\n" +
        "User input: " +
        userInput;
  }
}
