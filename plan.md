# Success - Habit Tracking App Implementation Plan

## Architecture Overview

**Tech Stack:**

- Flutter (cross-platform: iOS, Android, Web, Desktop)
- State Management: Riverpod or Provider (TBD during implementation)
- Local Database: SQLite (via sqflite) or Hive for persistence
- SLM Integration: Modular design supporting both local (Ollama) and API-based models

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── models/
│   │       ├── habit_model.dart
│   │       └── progress_model.dart
│   └── utils/
├── features/
│   ├── habits/
│   │   ├── data/
│   │   │   ├── habit_repository.dart
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── habits_list_page.dart
│   │   │   │   └── habit_detail_page.dart
│   │   │   └── widgets/
│   │   │       ├── habit_card.dart
│   │   │       └── habit_checkbox.dart
│   ├── progress/
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── progress_dashboard.dart
│   │   │   └── widgets/
│   │   │       └── streak_widget.dart
│   ├── gamification/
│   │   ├── data/
│   │   │   ├── gamification_repository.dart
│   │   │   └── models/
│   │   │       ├── user_stats_model.dart
│   │   │       └── achievement_model.dart
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── profile_page.dart (shows level, points, stats)
│   │   │   │   └── achievements_page.dart
│   │   │   └── widgets/
│   │   │       ├── points_display.dart
│   │   │       ├── level_indicator.dart
│   │   │       ├── achievement_badge.dart
│   │   │       └── leaderboard_widget.dart
│   └── assistant/
│       ├── data/
│       │   ├── slm_service.dart
│       │   ├── providers/
│       │   │   ├── ollama_provider.dart
│       │   │   └── api_provider.dart (for future API models)
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── assistant_chat_page.dart
│       │   └── widgets/
│       │       └── message_bubble.dart
└── pubspec.yaml
```

## Core Features (MVP)

### 1. Habit Management

- Create/edit/delete habits
- Mark habits as complete/incomplete for today
- View list of all habits
- Simple habit model: name, description, creation date

### 2. Progress Tracking

- Calculate and display streak count per habit
- Daily progress view (what's completed today)
- Basic statistics (total habits, completion rate)

### 3. SLM Assistant

- Chat interface for habit-related advice
- Context-aware responses (aware of user's habits and progress)
- Modular provider system to support different models
- Initial implementation: Configurable to use Ollama or API-based models

## Database Schema

**Habits Table:**

- id (primary key)
- name (text)
- description (text, nullable)
- created_at (datetime)
- updated_at (datetime)

**Progress Table:**

- id (primary key)
- habit_id (foreign key)
- date (date)
- completed (boolean)
- notes (text, nullable)

## SLM Integration Design

- **Service Interface**: Abstract `SLMService` class
- **Providers**: 
  - `OllamaProvider` - for local Ollama models
  - `APIModelProvider` - for cloud-based models (OpenAI, Anthropic, etc.)
- **Context Builder**: Prepares user's habit data to send to model
- **Flexible Configuration**: Easy to swap models or add fine-tuned versions

## UI/UX Approach

- Material Design 3 (Flutter's default)
- Clean, minimal interface
- Color-coded habit status (completed/incomplete)
- Streak indicators with visual feedback
- Chat-style assistant interface

## Implementation Steps

1. **Project Setup**: Initialize Flutter project, add dependencies (sqflite/hive, http for API calls)
2. **Data Layer**: Create database models and repositories
3. **Habit Management UI**: Build habit list and detail pages
4. **Progress Tracking**: Implement streak calculation and dashboard
5. **SLM Assistant Foundation**: Create service interface and Ollama provider
6. **Assistant UI**: Build chat interface
7. **Integration**: Connect assistant with habit data context
8. **Testing & Polish**: Basic testing and UI refinements

## Key Dependencies (pubspec.yaml)

- `sqflite` or `hive` - local database
- `http` - API calls for SLM
- `intl` - date formatting
- `flutter_riverpod` or `provider` - state management
- Optional: `dart_chat_ui` or custom chat widgets