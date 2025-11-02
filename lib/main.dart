import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'core/database/supabase_service.dart';
import 'features/habits/presentation/pages/habits_list_page.dart';
import 'features/progress/presentation/pages/progress_dashboard.dart';
import 'features/assistant/presentation/pages/assistant_chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // Note: For production, consider using platform-specific environment variables
  // or build-time configuration instead of bundling .env in assets
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('[Init] ✅ .env file loaded successfully');
  } catch (e) {
    debugPrint('[Init] ❌ Could not load .env file: $e');
    debugPrint(
        'Please create a .env file from .env.example in the project root');
    debugPrint('Make sure .env is listed in pubspec.yaml assets section');
  }

  // Initialize Supabase if configured
  if (AppConfig.useSupabase) {
    try {
      debugPrint('[Init] Initializing Supabase...');
      await SupabaseService.initialize();
      debugPrint('[Init] ✅ Supabase initialized successfully');
      debugPrint('[Init] Real-time sync is enabled');
    } catch (e, stackTrace) {
      debugPrint('[Init] ❌ Failed to initialize Supabase: $e');
      debugPrint('[Init] Stack trace: $stackTrace');
      debugPrint('[Init] App will continue but database operations will fail');
      // Don't throw - let the app show the error in the UI
    }
  } else {
    debugPrint('[Init] Supabase disabled in configuration');
  }

  runApp(
    const ProviderScope(
      child: SuccessApp(),
    ),
  );
}

class SuccessApp extends StatelessWidget {
  const SuccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Success - Habit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HabitsListPage(),
    const ProgressDashboard(),
    // ProfilePage disabled for now
    const AssistantChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          // Profile tab disabled for now
          NavigationDestination(
            icon: Icon(Icons.psychology),
            selectedIcon: Icon(Icons.psychology),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}
