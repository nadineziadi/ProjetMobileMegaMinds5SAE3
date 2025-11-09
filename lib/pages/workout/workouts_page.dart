// lib/pages/workout/workouts_page.dart
import 'package:flutter/cupertino.dart';
import 'workout_list_screen.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF353A40), // Top gradient color
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF353A40).withOpacity(0.9),
        border: null, // Remove bottom border
        middle: const Text(
          'Workouts',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: const WorkoutListScreen(),
    );
  }
}