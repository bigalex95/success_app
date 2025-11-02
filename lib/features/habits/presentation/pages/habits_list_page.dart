import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/models/habit_model.dart';
import '../../../../core/database/models/progress_model.dart';
import '../../../../core/database/supabase_service.dart';
import '../../data/habit_repository.dart';
import '../widgets/habit_card.dart';
import 'habit_detail_page.dart';
import '../../../progress/presentation/pages/progress_dashboard.dart'
    show completionStatsProvider, userStatsProvider;

final habitRepositoryProvider = Provider((ref) => HabitRepository());

final habitsProvider = FutureProvider<List<HabitModel>>((ref) async {
  final repository = ref.read(habitRepositoryProvider);
  return await repository.getAllHabits();
});

final todayProgressProvider = FutureProvider<Map<int, bool>>((ref) async {
  final repository = ref.read(habitRepositoryProvider);
  return await repository.getTodayProgress();
});

final habitStreaksProvider =
    FutureProvider.family<int, int>((ref, habitId) async {
  final repository = ref.read(habitRepositoryProvider);
  return await repository.calculateStreak(habitId);
});

class HabitsListPage extends ConsumerStatefulWidget {
  const HabitsListPage({super.key});

  @override
  ConsumerState<HabitsListPage> createState() => _HabitsListPageState();
}

class _HabitsListPageState extends ConsumerState<HabitsListPage> {
  @override
  void initState() {
    super.initState();

    // Only set up real-time if Supabase is initialized
    if (SupabaseService.isInitialized) {
      // Listen to real-time habit changes and refresh data
      SupabaseService.habitsStream.listen((_) {
        if (mounted) {
          debugPrint('[Realtime] Habits changed, refreshing data');
          ref.invalidate(habitsProvider);
          ref.invalidate(todayProgressProvider);
          ref.invalidate(habitStreaksProvider);
        }
      });

      // Listen to real-time progress changes and refresh data
      SupabaseService.progressStream.listen((_) {
        if (mounted) {
          debugPrint('[Realtime] Progress changed, refreshing data');
          ref.invalidate(todayProgressProvider);
          ref.invalidate(habitStreaksProvider);
          ref.invalidate(completionStatsProvider);
          ref.invalidate(userStatsProvider);
        }
      });
    } else {
      debugPrint(
          '[Realtime] ⚠️ Supabase not initialized, real-time sync disabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final todayProgressAsync = ref.watch(todayProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_task, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first habit',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return todayProgressAsync.when(
            data: (todayProgress) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(habitsProvider);
                  ref.invalidate(todayProgressProvider);
                },
                child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final isCompleted = todayProgress[habit.id] ?? false;

                    return Consumer(
                      builder: (context, ref, child) {
                        final streakAsync =
                            ref.watch(habitStreaksProvider(habit.id!));
                        return streakAsync.when(
                          data: (streak) {
                            return HabitCard(
                              habit: habit,
                              streak: streak,
                              isCompletedToday: isCompleted,
                              onTap: () {
                                debugPrint(
                                    '[Navigation] Opening habit detail for id: [1m${habit.id}[0m');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HabitDetailPage(habitId: habit.id!),
                                  ),
                                ).then((_) {
                                  debugPrint(
                                      '[Navigation] Returned from habit detail for id: ${habit.id}');
                                  ref.invalidate(habitsProvider);
                                  ref.invalidate(todayProgressProvider);
                                });
                              },
                              onCheckboxTap: () async {
                                final repository =
                                    ref.read(habitRepositoryProvider);
                                final today = DateTime.now();
                                final newStatus = !isCompleted;
                                debugPrint(
                                    '[Progress] Marking habit ${habit.id} as ${newStatus ? 'completed' : 'not completed'} for $today');
                                await repository.markProgress(
                                  ProgressModel(
                                    habitId: habit.id!,
                                    date: today,
                                    completed: newStatus,
                                  ),
                                );
                                debugPrint(
                                    '[Progress] Marked habit ${habit.id} as ${newStatus ? 'completed' : 'not completed'}');
                                // Invalidate all relevant providers for live updates
                                ref.invalidate(todayProgressProvider);
                                ref.invalidate(habitStreaksProvider(habit.id!));
                                ref.invalidate(completionStatsProvider);
                                ref.invalidate(userStatsProvider);
                                ref.invalidate(
                                    habitProgressProvider(habit.id!));
                              },
                            );
                          },
                          loading: () => const SizedBox(height: 100),
                          error: (_, __) => const SizedBox(height: 100),
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Exercise daily',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add more details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final repository = ref.read(habitRepositoryProvider);
                final now = DateTime.now();
                debugPrint(
                    '[Habit] Creating habit: ${nameController.text.trim()}');
                await repository.createHabit(
                  HabitModel(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
                debugPrint('[Habit] Created habit successfully');
                // Invalidate all relevant providers for live updates
                ref.invalidate(habitsProvider);
                ref.invalidate(todayProgressProvider);
                ref.invalidate(habitStreaksProvider);
                ref.invalidate(completionStatsProvider);
                ref.invalidate(userStatsProvider);
                ref.invalidate(habitProgressProvider);
                if (context.mounted) {
                  debugPrint('[Navigation] Closing add habit dialog');
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
