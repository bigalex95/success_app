import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'core/database/supabase_service.dart';
import 'features/habits/presentation/pages/habits_list_page.dart';
import 'features/progress/presentation/pages/progress_dashboard.dart';
import 'features/gamification/presentation/pages/profile_page.dart';
import 'features/assistant/presentation/pages/assistant_chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  // Note: For production, consider using platform-specific environment variables
  // or build-time configuration instead of bundling .env in assets
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Please create a .env file from .env.example in the project root');
    debugPrint('Make sure .env is listed in pubspec.yaml assets section');
  }
  
  // Initialize Supabase if configured
  if (AppConfig.useSupabase) {
    try {
      await SupabaseService.initialize();
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      // App will still run but database operations will fail
      // User should configure Supabase in .env file
    }
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
    const ProfilePage(),
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
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
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

