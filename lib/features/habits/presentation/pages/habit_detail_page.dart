import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/models/habit_model.dart';
import '../../../../core/database/models/progress_model.dart';
import '../../../../core/database/supabase_service.dart';
import 'habits_list_page.dart';
import '../../../progress/presentation/pages/progress_dashboard.dart'
    show completionStatsProvider, userStatsProvider;

class HabitDetailPage extends ConsumerStatefulWidget {
  final int habitId;

  const HabitDetailPage({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

final habitDetailProvider =
    FutureProvider.family<HabitModel?, int>((ref, habitId) async {
  debugPrint('[Detail] Loading habit detail for id: $habitId');
  final repository = ref.read(habitRepositoryProvider);
  final habit = await repository.getHabitById(habitId);
  debugPrint('[Detail] Loaded habit: ${habit?.name ?? 'null'}');
  return habit;
});

final habitProgressProvider =
    FutureProvider.family<List<ProgressModel>, int>((ref, habitId) async {
  debugPrint('[Detail] Loading progress for habit id: $habitId');
  final repository = ref.read(habitRepositoryProvider);
  final progress = await repository.getProgressForHabit(habitId, limit: 30);
  debugPrint('[Detail] Loaded progress count: ${progress.length}');
  return progress;
});

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  @override
  void initState() {
    super.initState();

    // Set up real-time listeners for this habit's data
    if (SupabaseService.isInitialized) {
      // Listen to habit changes (edit, delete)
      SupabaseService.habitsStream.listen((_) {
        if (mounted) {
          debugPrint('[Realtime] Habit changed, refreshing detail page');
          ref.invalidate(habitDetailProvider(widget.habitId));
          ref.invalidate(habitStreaksProvider(widget.habitId));
        }
      });

      // Listen to progress changes (mark complete/incomplete)
      SupabaseService.progressStream.listen((_) {
        if (mounted) {
          debugPrint(
              '[Realtime] Progress changed, refreshing habit detail progress');
          ref.invalidate(habitProgressProvider(widget.habitId));
          ref.invalidate(habitStreaksProvider(widget.habitId));
        }
      });
    } else {
      debugPrint(
          '[Realtime] ⚠️ Supabase not initialized, real-time sync disabled for habit detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitAsync = ref.watch(habitDetailProvider(widget.habitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              habitAsync.whenData((habit) {
                if (habit != null) {
                  _showEditHabitDialog(context, ref, habit);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              habitAsync.whenData((habit) {
                if (habit != null) {
                  _showDeleteConfirmation(context, ref);
                }
              });
            },
          ),
        ],
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return const Center(child: Text('Habit not found'));
          }

          return _buildHabitDetails(context, ref, habit);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildHabitDetails(
      BuildContext context, WidgetRef ref, HabitModel habit) {
    final streakAsync = ref.watch(habitStreaksProvider(habit.id!));
    final progressAsync = ref.watch(habitProgressProvider(habit.id!));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (habit.description != null &&
                      habit.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        habit.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange),
                      const SizedBox(width: 8),
                      streakAsync.when(
                        data: (streak) => Text(
                          '$streak day${streak != 1 ? 's' : ''} streak',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${DateFormat('MMM d, y').format(habit.createdAt)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          progressAsync.when(
            data: (progressList) {
              if (progressList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No progress recorded yet'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: progressList.length,
                itemBuilder: (context, index) {
                  final progress = progressList[index];
                  return ListTile(
                    leading: Icon(
                      progress.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: progress.completed ? Colors.green : Colors.grey,
                    ),
                    title: Text(DateFormat('MMM d, y').format(progress.date)),
                    subtitle:
                        progress.notes != null ? Text(progress.notes!) : null,
                    trailing: progress.completed
                        ? const Icon(Icons.done, color: Colors.green)
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  void _showEditHabitDialog(
      BuildContext context, WidgetRef ref, HabitModel habit) {
    final nameController = TextEditingController(text: habit.name);
    final descriptionController =
        TextEditingController(text: habit.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
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
                await repository.updateHabit(
                  habit.copyWith(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ),
                );
                ref.invalidate(habitsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Also close detail page
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
            'Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repository = ref.read(habitRepositoryProvider);
              await repository.deleteHabit(widget.habitId);
              // Invalidate all relevant providers for live updates
              ref.invalidate(habitsProvider);
              ref.invalidate(todayProgressProvider);
              ref.invalidate(habitStreaksProvider);
              ref.invalidate(completionStatsProvider);
              ref.invalidate(userStatsProvider);
              ref.invalidate(habitProgressProvider);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close detail page
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
