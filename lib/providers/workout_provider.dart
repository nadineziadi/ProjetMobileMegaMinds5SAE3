import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../services/workout_database.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  bool isLoading = false;
  String? error;

  List<Workout> get workouts => _workouts;

  Future<void> loadWorkouts() async {
    try {
      isLoading = true;
      notifyListeners();

      _workouts = await WorkoutDatabase.instance.readAll();
      error = null;
    } catch (e) {
      error = 'Erreur lors du chargement : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout(Workout workout) async {
    await WorkoutDatabase.instance.create(workout);
    await loadWorkouts();
  }

  Future<void> updateWorkout(Workout workout) async {
    await WorkoutDatabase.instance.update(workout);
    await loadWorkouts();
  }

  Future<void> deleteWorkout(int id) async {
    await WorkoutDatabase.instance.delete(id);
    await loadWorkouts();
  }

  // ✅ Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    int totalWorkouts = _workouts.length;
    int totalDuration = _workouts.fold(0, (sum, w) => sum + w.duration);
    int totalCalories = _workouts.fold(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

    return {
      'totalWorkouts': totalWorkouts,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
    };
  }

  int getWeeklyDuration() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return _workouts
        .where((w) => w.date.isAfter(startOfWeek))
        .fold(0, (sum, w) => sum + w.duration);
  }

  int getWeeklyCalories() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return _workouts
        .where((w) => w.date.isAfter(startOfWeek))
        .fold(0, (sum, w) => sum + (w.caloriesBurned ?? 0));
  }
}
