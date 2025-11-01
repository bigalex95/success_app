import 'package:flutter/material.dart';

class HabitCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;
  final double size;

  const HabitCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked ? Colors.green : Colors.transparent,
          border: Border.all(
            color: isChecked ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: isChecked
            ? Icon(Icons.check, color: Colors.white, size: size * 0.6)
            : null,
      ),
    );
  }
}

