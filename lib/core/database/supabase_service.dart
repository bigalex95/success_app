import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Supabase service for database operations
/// This works across all platforms: Web, Android, iOS, Linux, Windows, macOS
class SupabaseService {
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  /// Initialize Supabase client
  /// Should be called in main() before runApp()
  static Future<void> initialize() async {
    if (AppConfig.supabaseUrl == 'YOUR_SUPABASE_URL' || 
        AppConfig.supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY') {
      throw Exception(
        'Please configure Supabase in app_config.dart:\n'
        '1. Go to https://app.supabase.com\n'
        '2. Create a new project (or use existing)\n'
        '3. Go to Settings -> API\n'
        '4. Copy the URL and anon key\n'
        '5. Update AppConfig.supabaseUrl and AppConfig.supabaseAnonKey'
      );
    }
    
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    
    _client = Supabase.instance.client;
  }
  
  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
}

