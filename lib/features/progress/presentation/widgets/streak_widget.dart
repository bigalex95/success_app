import 'package:flutter/material.dart';

class StreakWidget extends StatelessWidget {
  final int streak;
  final String? habitName;

  const StreakWidget({
    super.key,
    required this.streak,
    this.habitName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: streak > 0 ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                color: streak > 0 ? Colors.orange : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habitName != null ? '$habitName Streak' : 'Current Streak',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$streak day${streak != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: streak > 0 ? Colors.orange : Colors.grey,
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

