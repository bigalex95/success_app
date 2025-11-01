import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // SLM Configuration
  static const String defaultSLMProvider = 'ollama'; // 'ollama' or 'api'
  
  // Ollama Configuration
  static String get ollamaBaseUrl => dotenv.env['OLLAMA_BASE_URL'] ?? 'http://localhost:11434';
  static String get ollamaModel => dotenv.env['OLLAMA_MODEL'] ?? 'llama3.2';
  
  // API Configuration (for future use)
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  
  // Supabase Configuration
  // Load from .env file - create .env from .env.example and add your keys
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty || url == 'YOUR_SUPABASE_URL') {
      throw Exception(
        'Supabase URL not configured!\n'
        'Please create a .env file from .env.example and add your Supabase credentials.\n'
        'Get them from: https://app.supabase.com -> Your Project -> Settings -> API'
      );
    }
    return url;
  }
  
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty || key == 'YOUR_SUPABASE_ANON_KEY') {
      throw Exception(
        'Supabase anon key not configured!\n'
        'Please create a .env file from .env.example and add your Supabase credentials.\n'
        'Get them from: https://app.supabase.com -> Your Project -> Settings -> API'
      );
    }
    return key;
  }
  
  // Database Configuration
  static bool get useSupabase {
    final value = dotenv.env['USE_SUPABASE'];
    return value?.toLowerCase() != 'false';
  }
  
  // App Settings
  static const String appName = 'Success';
  static const bool enableGamification = true;
  
  // Streak calculation
  static const int streakBufferDays = 1; // Allow 1 day buffer for missed days
}

