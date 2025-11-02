import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../habits/data/habit_repository.dart';
import '../../../gamification/data/gamification_repository.dart';
import '../../../gamification/data/models/user_stats_model.dart';
import '../../../habits/presentation/pages/habits_list_page.dart';
import '../widgets/streak_widget.dart';

final habitRepositoryProviderForProgress = Provider((ref) => HabitRepository());

final completionStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(habitRepositoryProviderForProgress);
  return await repository.getCompletionStats();
});

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final repository = GamificationRepository();
  return await repository.getUserStats();
});

class ProgressDashboard extends ConsumerStatefulWidget {
  const ProgressDashboard({super.key});

  @override
  ConsumerState<ProgressDashboard> createState() => _ProgressDashboardState();
}

class _ProgressDashboardState extends ConsumerState<ProgressDashboard> {
  @override
  void initState() {
    super.initState();

    // Only set up real-time if Supabase is initialized
    if (SupabaseService.isInitialized) {
      // Listen to real-time changes and refresh stats
      SupabaseService.progressStream.listen((_) {
        if (mounted) {
          debugPrint('[Realtime] Progress changed, refreshing dashboard');
          ref.invalidate(completionStatsProvider);
          ref.invalidate(userStatsProvider);
        }
      });

      SupabaseService.habitsStream.listen((_) {
        if (mounted) {
          debugPrint('[Realtime] Habits changed, refreshing dashboard');
          ref.invalidate(completionStatsProvider);
        }
      });
    } else {
      debugPrint(
          '[Realtime] ⚠️ Supabase not initialized, real-time sync disabled for dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ProgressDashboard] Building dashboard UI');
    final statsAsync = ref.watch(completionStatsProvider);
    final userStatsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(completionStatsProvider);
          ref.invalidate(userStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      statsAsync.when(
                        data: (stats) {
                          final total = stats['totalHabits'] as int;
                          final completed = stats['completedToday'] as int;
                          final rate = stats['completionRate'] as double;

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$completed / $total',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Habits completed',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  CircularProgressIndicator(
                                    value: rate,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      rate > 0.5 ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: rate,
                                backgroundColor: Colors.grey[300],
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  rate > 0.5 ? Colors.green : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(rate * 100).toStringAsFixed(1)}% complete',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // User Stats
              userStatsAsync.when(
                data: (userStats) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    const Icon(Icons.emoji_events,
                                        size: 32, color: Colors.amber),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${userStats.level}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Level',
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
                                    const Icon(Icons.stars,
                                        size: 32, color: Colors.blue),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${userStats.totalPoints}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Points',
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
                      StreakWidget(
                        streak: userStats.longestStreak,
                        habitName: null,
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HabitsListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.view_list),
                label: const Text('View All Habits'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
