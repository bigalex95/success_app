# Success - Habit Tracking App

A comprehensive Flutter app for tracking habits with gamification and AI assistant integration.

## Features

- **Habit Management**: Create, edit, and delete habits with easy tracking
- **Progress Tracking**: Visualize your progress with streaks and statistics
- **Gamification**: Earn points, level up, and unlock achievements
- **AI Assistant**: Get personalized habit advice powered by SLM (Small Language Model)

## Tech Stack

- Flutter 3.0+
- Riverpod for state management
- SQLite for local database
- Ollama integration for local AI models
- Material Design 3

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure the app:
   - Edit `lib/core/config/app_config.dart` to configure SLM provider settings
   - For Ollama: Ensure Ollama is running locally at `http://localhost:11434`
   - Update the model name if needed (default: `llama3.2`)

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── config/          # App configuration
│   ├── database/        # Database models and helper
│   └── utils/           # Utility functions
└── features/
    ├── habits/          # Habit management
    ├── progress/        # Progress tracking
    ├── gamification/    # Points, levels, achievements
    └── assistant/       # AI assistant integration
```

## SLM Integration

The app supports multiple SLM providers:
- **Ollama** (default): Local models via Ollama
- **API**: Cloud-based models (OpenAI, Anthropic, etc.)

Configure in `app_config.dart`:
- `defaultSLMProvider`: Choose 'ollama' or 'api'
- `ollamaBaseUrl`: Ollama server URL
- `ollamaModel`: Model name to use
- `apiBaseUrl` & `apiKey`: For API-based providers

## Database Schema

- **habits**: Stores habit information
- **progress**: Tracks daily completion status

## Development

The app uses:
- Riverpod for state management and dependency injection
- SQLite via sqflite for persistence
- Material Design 3 for UI components

## License

MIT License

