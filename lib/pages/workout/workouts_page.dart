// lib/pages/workout/workouts_page.dart
import 'package:flutter/cupertino.dart';
import 'workout_list_screen.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Workouts'),
      ),
      child: SafeArea(
        child: WorkoutListScreen(),
      ),
    );
  }
}
