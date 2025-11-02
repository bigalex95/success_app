# Success - Habit Tracking App

A comprehensive Flutter app for tracking habits with gamification and AI assistant integration, featuring **real-time synchronization** across all devices.

## ✨ Features

- **Habit Management**: Create, edit, and delete habits with easy tracking
- **Real-Time Sync**: Changes sync instantly across all devices (Web, Linux, Android, iOS)
- **Progress Tracking**: Visualize your progress with streaks and statistics
- **Gamification**: Earn points, level up, and unlock achievements
- **AI Assistant**: Get personalized habit advice with multiple AI provider options (Gemini, Ollama, OpenAI)
- **Cross-Platform**: Works on Web, Linux, Windows, macOS, Android, iOS

## 🛠 Tech Stack

- **Frontend**: Flutter 3.0+ with Material Design 3
- **State Management**: Riverpod
- **Database**: Supabase (PostgreSQL) with real-time subscriptions
- **AI Integration**:
  - Google Gemini API
  - Ollama (local models)
  - OpenAI-compatible APIs
- **Real-Time**: Supabase Real-time (WebSocket-based)

## 🚀 Quick Setup

1. **Clone and install dependencies**:

```bash
git clone <repository-url>
cd success_app
flutter pub get
```

2. **Configure environment variables**:

   - Copy `.env.example` to `.env`
   - Add your Supabase credentials (see `docs/SUPABASE_SETUP.md`)
   - Add your AI provider API key (see `docs/AI_PROVIDER_SETUP.md`)

3. **Set up database**:

   - Run SQL scripts in `database/` folder in your Supabase project
   - Enable real-time: `database/enable_realtime.sql`

4. **Run the app**:

```bash
# For Linux
flutter run -d linux

# For Web (Chrome)
flutter run -d chrome

# For Android
flutter run -d android
```

## 📚 Documentation

All documentation is in the `docs/` folder:

- **[Quick Start Guide](docs/QUICK_START.md)** - Get started quickly
- **[Supabase Setup](docs/SUPABASE_SETUP.md)** - Database configuration
- **[AI Provider Setup](docs/AI_PROVIDER_SETUP.md)** - Configure Gemini, Ollama, or OpenAI
- **[Real-Time Sync](docs/REALTIME_SETUP.md)** - How real-time sync works
- **[Environment Variables](docs/README_ENV.md)** - All .env options

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

## 🤖 AI Integration

The app supports multiple AI providers:

- **Google Gemini** (Recommended): Fast and free tier available
- **Ollama**: Local models for privacy (requires local installation)
- **OpenAI/Anthropic**: API-compatible services

Configure in `.env`:

```env
SLM_PROVIDER=gemini  # or 'ollama', 'api'
GEMINI_API_KEY=your_key_here
GEMINI_MODEL=gemini-2.5-flash
```

The assistant can:

- Parse natural language to create habits
- Provide personalized habit advice
- Answer questions about your progress
- Messages sync in real-time across devices

## 💾 Database

Powered by Supabase (PostgreSQL):

- **habits**: Habit definitions and metadata
- **progress**: Daily completion tracking
- **assistant_conversations**: AI chat history

SQL setup scripts in `database/` folder.

## 🔄 Real-Time Synchronization

Changes sync **instantly** across all devices:

- Create a habit on web → appears immediately on mobile
- Mark progress on mobile → updates instantly on desktop
- Send chat message → appears in all connected instances

Built with Supabase Real-time using WebSocket connections.

## 🏗 Development

**Architecture**:

- **State Management**: Riverpod with providers
- **Database Layer**: Supabase client with real-time subscriptions
- **UI**: Material Design 3 with responsive layouts
- **Real-Time**: Stream-based updates with automatic cache invalidation

**Project Structure**:

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── config/                  # App configuration
│   └── database/                # Supabase service & models
└── features/
    ├── habits/                  # Habit CRUD & UI
    ├── progress/                # Analytics & dashboards
    ├── gamification/            # Points & achievements
    └── assistant/               # AI chat interface
```

**Database Scripts**:

```
database/
├── supabase_setup.sql          # Initial database schema
└── enable_realtime.sql         # Enable real-time subscriptions
```

## 🤝 Contributing

Contributions are welcome! Please check existing issues or create new ones.

## 📄 License

MIT License
