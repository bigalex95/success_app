import 'package:flutter/material.dart';

class LevelIndicator extends StatelessWidget {
  final int level;
  final int totalPoints;
  final int pointsToNextLevel;

  const LevelIndicator({
    super.key,
    required this.level,
    required this.totalPoints,
    required this.pointsToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final pointsForCurrentLevel = (level - 1) * 100;
    final pointsInCurrentLevel = totalPoints - pointsForCurrentLevel;
    final progress = pointsInCurrentLevel / 100;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$pointsToNextLevel points to Level ${level + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '$pointsInCurrentLevel / 100',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

