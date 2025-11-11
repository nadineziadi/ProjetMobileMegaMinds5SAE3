import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user_progress.dart';

class StatisticsProvider extends ChangeNotifier {
  int _totalCompletedWorkouts = 0;
  double _weeklyCompletionRate = 0.0;
  double _averageFatigueLevel = 0.0;
  int _currentStreak = 0;
  List<WorkoutLog> _recentLogs = [];
  
  int get totalCompletedWorkouts => _totalCompletedWorkouts;
  double get weeklyCompletionRate => _weeklyCompletionRate;
  double get averageFatigueLevel => _averageFatigueLevel;
  int get currentStreak => _currentStreak;
  List<WorkoutLog> get recentLogs => _recentLogs;

  Future<void> loadStatistics() async {
    _totalCompletedWorkouts = await DatabaseHelper.instance.getTotalCompletedWorkouts();
    _weeklyCompletionRate = await DatabaseHelper.instance.getWeeklyCompletionRate();
    _averageFatigueLevel = await DatabaseHelper.instance.getAverageFatigueLevel();
    _currentStreak = await DatabaseHelper.instance.getCurrentStreak();
    _recentLogs = await DatabaseHelper.instance.getRecentWorkoutLogs(limit: 30);
    notifyListeners();
  }

  // Get workout logs grouped by date for last 7 days
  Map<String, int> getWeeklyWorkoutData() {
    final now = DateTime.now();
    final Map<String, int> data = {};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';
      data[dateKey] = 0;
    }
    
    for (var log in _recentLogs) {
      if (log.completed) {
        final logDate = log.date;
        final dateKey = '${logDate.month}/${logDate.day}';
        if (data.containsKey(dateKey)) {
          data[dateKey] = data[dateKey]! + 1;
        }
      }
    }
    
    return data;
  }

  // Get average fatigue by day for last 7 days
  Map<String, double> getWeeklyFatigueData() {
    final now = DateTime.now();
    final Map<String, List<int>> fatigueByDay = {};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';
      fatigueByDay[dateKey] = [];
    }
    
    for (var log in _recentLogs) {
      if (log.completed && log.fatigueLevel != null) {
        final logDate = log.date;
        final dateKey = '${logDate.month}/${logDate.day}';
        if (fatigueByDay.containsKey(dateKey)) {
          fatigueByDay[dateKey]!.add(log.fatigueLevel!);
        }
      }
    }
    
    // Calculate averages
    final Map<String, double> averages = {};
    fatigueByDay.forEach((key, values) {
      if (values.isNotEmpty) {
        averages[key] = values.reduce((a, b) => a + b) / values.length;
      } else {
        averages[key] = 0;
      }
    });
    
    return averages;
  }
}