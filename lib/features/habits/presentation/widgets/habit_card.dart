import 'package:flutter/material.dart';
import '../../../../core/database/models/habit_model.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final int streak;
  final bool isCompletedToday;
  final VoidCallback onTap;
  final VoidCallback onCheckboxTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.isCompletedToday,
    required this.onTap,
    required this.onCheckboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onCheckboxTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompletedToday ? Colors.green : Colors.grey[300],
                    border: Border.all(
                      color: isCompletedToday ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isCompletedToday
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (habit.description != null && habit.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          habit.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, 
                             color: streak > 0 ? Colors.orange : Colors.grey,
                             size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$streak day${streak != 1 ? 's' : ''} streak',
                          style: TextStyle(
                            fontSize: 12,
                            color: streak > 0 ? Colors.orange : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

