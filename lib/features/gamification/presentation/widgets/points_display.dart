import 'package:flutter/material.dart';

class PointsDisplay extends StatelessWidget {
  final int points;
  final int? pointsToNextLevel;

  const PointsDisplay({
    super.key,
    required this.points,
    this.pointsToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, size: 32, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Total Points',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (pointsToNextLevel != null) ...[
              const SizedBox(height: 16),
              Text(
                '$pointsToNextLevel points to next level',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

