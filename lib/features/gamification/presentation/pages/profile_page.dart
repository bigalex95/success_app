import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gamification_repository.dart';
import '../../../progress/presentation/pages/progress_dashboard.dart';
import '../widgets/points_display.dart';
import '../widgets/level_indicator.dart';
import 'achievements_page.dart';

import '../../data/models/user_stats_model.dart';

final gamificationRepositoryProvider = Provider((ref) => GamificationRepository());

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final repository = GamificationRepository();
  return await repository.getUserStats();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: userStatsAsync.when(
            data: (userStats) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level Indicator
                  LevelIndicator(
                    level: userStats.level,
                    totalPoints: userStats.totalPoints,
                    pointsToNextLevel: userStats.pointsToNextLevel,
                  ),
                  const SizedBox(height: 16),
                  
                  // Points Display
                  PointsDisplay(
                    points: userStats.totalPoints,
                    pointsToNextLevel: userStats.pointsToNextLevel,
                  ),
                  const SizedBox(height: 16),

                  // Statistics Grid
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.task_alt, size: 32, color: Colors.green),
                                const SizedBox(height: 8),
                                Text(
                                  '${userStats.totalHabits}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Habits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.local_fire_department, size: 32, color: Colors.orange),
                                const SizedBox(height: 8),
                                Text(
                                  '${userStats.longestStreak}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Best Streak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle, size: 32, color: Colors.blue),
                                const SizedBox(height: 8),
                                Text(
                                  '${userStats.completedToday}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('View Achievements'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProgressDashboard(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('View Progress'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }
}

