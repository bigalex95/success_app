import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gamification_repository.dart';
import '../../data/models/achievement_model.dart';
import '../widgets/achievement_badge.dart';

final achievementsProvider = FutureProvider<List<AchievementModel>>((ref) async {
  final repository = GamificationRepository();
  return await repository.checkAndUnlockAchievements();
});

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(achievementsProvider);
        },
        child: achievementsAsync.when(
          data: (achievements) {
            if (achievements.isEmpty) {
              return const Center(
                child: Text('No achievements available'),
              );
            }

            final unlockedCount = achievements.where((a) => a.unlocked).length;
            final totalCount = achievements.length;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '$unlockedCount / $totalCount Achievements',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AchievementBadge(
                          achievement: achievements[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

