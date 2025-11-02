feat: Add multi-provider AI assistant, real-time sync, and improve project structure

## 🤖 AI Assistant Features

### Multi-Provider Support
- Added support for multiple AI providers (Gemini, Ollama, OpenAI-compatible APIs)
- Implemented Google Gemini API integration as the recommended provider
- Maintained Ollama support for local/offline AI processing
- Added OpenAI-compatible API support for flexibility

### Assistant Chat Improvements
- Added "Create Habit" button directly in assistant chat interface
- Implemented natural language habit parsing from AI responses
- Enhanced conversation context with recent chat history
- Added persistent conversation storage in Supabase
- Integrated habit creation workflow with AI suggestions

### Files Changed:
- `lib/features/assistant/data/slm_service.dart` - Multi-provider factory
- `lib/features/assistant/data/assistant_habit_parser.dart` - NLP habit extraction
- `lib/features/assistant/presentation/pages/assistant_chat_page.dart` - UI enhancements
- `lib/core/config/app_config.dart` - Multi-provider configuration

## ⚡ Real-Time Synchronization

### Core Real-Time Infrastructure
- Implemented Supabase real-time subscriptions using WebSocket
- Added real-time streams for habits, progress, and assistant conversations
- Created centralized `SupabaseService` with stream controllers
- Enabled cross-platform, cross-device instant sync

### Real-Time Coverage
- **Habits List Page**: Auto-updates on create, edit, delete, complete
- **Habit Detail Page**: Live progress updates, streak changes, edits
- **Progress Dashboard**: Real-time stats, completion rates, user stats
- **Assistant Chat**: Instant message sync across all devices

### Platform Compatibility Fixes
- Fixed `shared_preferences` plugin issue on Linux
- Disabled persistent auth storage to resolve Linux initialization errors
- Added safety checks for Supabase initialization before real-time setup
- Improved error logging for initialization debugging

### Files Changed:
- `lib/core/database/supabase_service.dart` - Real-time infrastructure
- `lib/features/habits/presentation/pages/habits_list_page.dart` - Real-time listeners
- `lib/features/habits/presentation/pages/habit_detail_page.dart` - Real-time listeners
- `lib/features/progress/presentation/pages/progress_dashboard.dart` - Real-time listeners
- `lib/features/assistant/presentation/pages/assistant_chat_page.dart` - Real-time listeners
- `lib/main.dart` - Enhanced initialization logging
- `pubspec.yaml` - Added shared_preferences dependency

## 📁 Project Structure Improvements

### Documentation Organization
- Created `docs/` folder for all documentation
- Moved setup guides, tutorials, and technical docs to `docs/`
- Updated README with better structure and quick start guide
- Added comprehensive real-time sync documentation

Moved files:
- `AI_PROVIDER_SETUP.md` → `docs/`
- `OLLAMA_SETUP.md` → `docs/`
- `QUICK_START.md` → `docs/`
- `README_ENV.md` → `docs/`
- `SUPABASE_SETUP.md` → `docs/`
- `Flutter_Dart_Tutorial.md` → `docs/`
- `REALTIME_SETUP.md` → `docs/`
- `REALTIME_FIXES.md` → `docs/`
- `plan.md` → `docs/`

### Database Scripts Organization
- Created `database/` folder for SQL scripts
- Organized database setup and configuration scripts
- Added real-time enablement script

Moved files:
- `supabase_setup.sql` → `database/`
- `enable_realtime.sql` → `database/`

### Updated Files:
- `README.md` - Complete rewrite with new features, better structure
- Added sections for: Features, Tech Stack, Quick Setup, AI Integration, Real-Time Sync

## 🔧 Technical Improvements

### Database Layer
- Enhanced `DatabaseHelperSupabase` with better error handling
- Added comprehensive logging for debugging
- Improved streak calculation logic
- Added real-time support for all database operations

### State Management
- Converted pages to `ConsumerStatefulWidget` for real-time support
- Added proper lifecycle management for stream subscriptions
- Implemented automatic cache invalidation on real-time events
- Added mounted checks to prevent memory leaks

### Error Handling
- Added detailed initialization logging with ✅/❌ indicators
- Improved error messages for configuration issues
- Added fallback behavior when Supabase fails to initialize
- Enhanced debugging with `[Init]` and `[Realtime]` log prefixes

## 🧪 Testing & Verification

### Real-Time Testing
- Verified sync works between Linux and Chrome instances
- Tested habit creation, editing, deletion across devices
- Confirmed progress tracking updates in real-time
- Validated assistant chat message synchronization

### Platform Testing
- Fixed and tested Linux desktop app
- Verified web (Chrome) compatibility
- Ensured real-time works across all platforms

## 📊 Impact

### User Experience
- Zero manual refresh needed - everything updates instantly
- Work seamlessly across multiple devices
- AI assistant more accessible with direct habit creation
- Better organized documentation for easier onboarding

### Developer Experience
- Clean project structure with organized docs
- Clear separation of database scripts
- Better debugging with enhanced logging
- Comprehensive documentation for all features

## 🔜 Future Enhancements

- Add connection status indicator in UI
- Implement offline mode with sync queue
- Add conflict resolution for simultaneous edits
- Multi-user support with user-specific channels
- Add more AI providers (Anthropic Claude, etc.)

---

**Breaking Changes**: None

**Migration Required**: 
1. Run `database/enable_realtime.sql` in Supabase to enable real-time
2. Update `.env` file with AI provider credentials (see `docs/AI_PROVIDER_SETUP.md`)

**Dependencies Added**:
- `shared_preferences: ^2.2.2` - For cross-platform storage support
