import 'package:intl/intl.dart';
import '../models/workout_model.dart';

class WorkoutStatsService {
  static Map<String, dynamic> calculateStats(List<Workout> workouts) {
    final now = DateTime.now();
    
    final totalCalories = workouts.fold(0, (sum, w) => sum + (w.caloriesBurned ?? 0));
    final totalDuration = workouts.fold(0, (sum, w) => sum + (w.duration ?? 0));
    
    // Calculate workouts per week
    final oldestDate = workouts.isEmpty
        ? now
        : workouts.map((w) => w.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final weeks = now.difference(oldestDate).inDays / 7;
    final avgPerWeek = weeks > 0 ? (workouts.length / weeks).round() : 0;
    
    // Group by type
    final byType = <String, Map<String, dynamic>>{};
    for (var workout in workouts) {
      if (!byType.containsKey(workout.type)) {
        byType[workout.type] = {
          'count': 0,
          'duration': 0,
          'calories': 0,
        };
      }
      byType[workout.type]!['count']++;
      byType[workout.type]!['duration'] += workout.duration ?? 0;
      byType[workout.type]!['calories'] += workout.caloriesBurned ?? 0;
    }
    
    // Add percentages
    byType.forEach((key, value) {
      value['percentage'] = workouts.isEmpty
          ? 0
          : ((value['count'] / workouts.length) * 100).round();
    });
    
    // Last 7 days activity
    final last7Days = <Map<String, dynamic>>[];
    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = workouts.where((w) =>
          w.date.year == date.year &&
          w.date.month == date.month &&
          w.date.day == date.day).length;
      
      last7Days.add({
        'date': DateFormat('EEEE d MMM', 'fr').format(date),
        'count': count,
      });
    }
    
    return {
      'total': workouts.length,
      'totalCalories': totalCalories,
      'totalDuration': totalDuration,
      'avgPerWeek': avgPerWeek,
      'byType': byType,
      'last7Days': last7Days,
    };
  }
}