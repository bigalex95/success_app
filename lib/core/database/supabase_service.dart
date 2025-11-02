import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Supabase service for database operations
/// This works across all platforms: Web, Android, iOS, Linux, Windows, macOS
class SupabaseService {
  static SupabaseClient? _client;

  // Stream controllers for real-time updates
  static final _habitsController = StreamController<void>.broadcast();
  static final _progressController = StreamController<void>.broadcast();
  static final _assistantController = StreamController<void>.broadcast();

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Stream for habit changes (insert, update, delete)
  static Stream<void> get habitsStream => _habitsController.stream;

  /// Stream for progress changes (insert, update, delete)
  static Stream<void> get progressStream => _progressController.stream;

  /// Stream for assistant conversation changes (insert, update, delete)
  static Stream<void> get assistantStream => _assistantController.stream;

  /// Initialize Supabase client
  /// Should be called in main() before runApp()
  static Future<void> initialize() async {
    if (AppConfig.supabaseUrl == 'YOUR_SUPABASE_URL' ||
        AppConfig.supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY') {
      throw Exception('Please configure Supabase in app_config.dart:\n'
          '1. Go to https://app.supabase.com\n'
          '2. Create a new project (or use existing)\n'
          '3. Go to Settings -> API\n'
          '4. Copy the URL and anon key\n'
          '5. Update AppConfig.supabaseUrl and AppConfig.supabaseAnonKey');
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      // Disable local storage on Linux to avoid shared_preferences issues
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: null, // Disable persistent auth storage
      ),
      // Enable real-time for automatic syncing
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _client = Supabase.instance.client;

    // Set up real-time subscriptions
    _setupRealtimeSubscriptions();
  }

  /// Set up real-time subscriptions for automatic data sync
  static void _setupRealtimeSubscriptions() {
    if (_client == null) {
      print('[Realtime] ⚠️ Client not initialized, skipping real-time setup');
      return;
    }

    try {
      print('[Realtime] Setting up subscriptions...');

      // Subscribe to habits table changes
      _client!
          .channel('public:habits')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'habits',
            callback: (payload) {
              print(
                  '[Realtime] ✅ Habits change detected: ${payload.eventType}');
              _habitsController.add(null);
            },
          )
          .subscribe();

      // Subscribe to progress table changes
      _client!
          .channel('public:progress')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'progress',
            callback: (payload) {
              print(
                  '[Realtime] ✅ Progress change detected: ${payload.eventType}');
              _progressController.add(null);
            },
          )
          .subscribe();

      // Subscribe to assistant_conversations table changes
      _client!
          .channel('public:assistant_conversations')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'assistant_conversations',
            callback: (payload) {
              print(
                  '[Realtime] ✅ Assistant message change detected: ${payload.eventType}');
              _assistantController.add(null);
            },
          )
          .subscribe();

      print('[Realtime] ✅ Subscriptions set up successfully');
    } catch (e, stackTrace) {
      print('[Realtime] ❌ Failed to set up subscriptions: $e');
      print('[Realtime] Stack trace: $stackTrace');
    }
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;

  /// Clean up resources
  static void dispose() {
    _habitsController.close();
    _progressController.close();
    _assistantController.close();
  }
}
