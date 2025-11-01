import 'package:flutter/material.dart';
import '../../../gamification/data/models/achievement_model.dart';

class AchievementBadge extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementBadge({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: achievement.unlocked ? 4 : 1,
      color: achievement.unlocked ? null : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: achievement.unlocked
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: achievement.unlocked ? null : Colors.grey,
                          ),
                        ),
                      ),
                      if (achievement.unlocked)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: achievement.unlocked ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                  if (achievement.unlocked && achievement.unlockedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Unlocked: ${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

