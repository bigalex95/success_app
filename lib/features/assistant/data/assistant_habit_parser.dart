import 'dart:convert';

/// Represents a parsed habit suggestion (basic)
class ParsedHabitSuggestion {
  final String name;
  final String? description;
  ParsedHabitSuggestion(this.name, [this.description]);
}

/// Represents a parsed habit suggestion from JSON format
class ParsedHabitSuggestionJson extends ParsedHabitSuggestion {
  final String? frequency;
  ParsedHabitSuggestionJson(
    String name, {
    String? description,
    String? frequency,
  })  : frequency = frequency,
        super(name, description);
}

/// Parses assistant messages for habit suggestions
class AssistantHabitParser {
  /// Returns ParsedHabitSuggestion or ParsedHabitSuggestionJson if found, otherwise null.
  /// This method returns only the FIRST habit found in the message.
  static ParsedHabitSuggestion? parseHabitSuggestion(String message) {
    final habits = parseAllHabitSuggestions(message);
    return habits.isNotEmpty ? habits.first : null;
  }

  /// Parses ALL habit suggestions from the message and returns a list.
  /// This is useful when the assistant generates multiple habits at once.
  static List<ParsedHabitSuggestion> parseAllHabitSuggestions(String message) {
    final List<ParsedHabitSuggestion> habits = [];

    // Try to parse JSON format for new habits
    try {
      final jsonPattern = RegExp(r'\{[\s\S]*?\}', multiLine: true);
      final jsonMatches = jsonPattern.allMatches(message);

      for (final jsonMatch in jsonMatches) {
        final jsonString = jsonMatch.group(0);
        if (jsonString != null) {
          try {
            final Map<String, dynamic> habitMap = jsonDecode(jsonString);
            final name = habitMap['habit_name']?.toString();
            final description = habitMap['description']?.toString();
            final frequency = habitMap['frequency']?.toString();
            if (name != null && name.isNotEmpty) {
              habits.add(ParsedHabitSuggestionJson(
                name,
                description: description,
                frequency: frequency,
              ));
            }
          } catch (_) {
            // Skip invalid JSON objects
            continue;
          }
        }
      }

      if (habits.isNotEmpty) {
        return habits;
      }
    } catch (_) {
      // Ignore JSON parse errors, fallback to previous patterns
    }

    // Structured format: Add habit: ... | Description: ...
    final structuredPattern = RegExp(
        r'Add habit: (.+?)(?:\s*\|\s*Description:\s*(.+))?$',
        caseSensitive: false);
    final match = structuredPattern.firstMatch(message);
    if (match != null) {
      final name = match.group(1)?.trim();
      final description = match.group(2)?.trim();
      if (name != null && name.isNotEmpty) {
        habits.add(ParsedHabitSuggestion(name, description));
        return habits;
      }
    }

    // Fallback: previous patterns
    final patterns = [
      RegExp(r'Add habit: (.+)', caseSensitive: false),
      RegExp(r'New habit: (.+)', caseSensitive: false),
      RegExp(r'You should try ([^.]+)', caseSensitive: false),
      RegExp(r'Start doing ([^.]+)', caseSensitive: false),
      RegExp(r'Consider ([^.]+)', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount > 0) {
        final name = match.group(1)?.trim();
        if (name != null && name.isNotEmpty) {
          habits.add(ParsedHabitSuggestion(name));
          return habits;
        }
      }
    }

    return habits;
  }
}

/// Example usage:
void exampleParseAssistantResponse() {
  const assistantResponse = '''
  {
    "habit_name": "Drink Water",
    "description": "Need to drink water everyday for health",
    "frequency": "Daily",
  // "start_date": "2025-11-02" // removed, handled automatically
  }
  ''';

  final parsed = AssistantHabitParser.parseHabitSuggestion(assistantResponse);
  if (parsed is ParsedHabitSuggestionJson) {
    print('Habit name: \\${parsed.name}');
    print('Description: \\${parsed.description}');
    print('Frequency: \\${parsed.frequency}');
    // print('Start date: \\${parsed.startDate}'); // removed, handled automatically
  } else if (parsed is ParsedHabitSuggestion) {
    print('Habit name: \\${parsed.name}');
    print('Description: \\${parsed.description}');
  } else {
    print('No habit found in response.');
  }
}
