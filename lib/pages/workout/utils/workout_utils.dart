import 'package:flutter/material.dart';

class WorkoutUtils {
  static Color getWorkoutColor(String type) {
    switch (type) {
      case 'Cardio':
        return const Color(0xFFFF6B6B);
      case 'Force':
        return const Color(0xFFFF8E53);
      case 'Étirement':
        return const Color(0xFF4ECDC4);
      case 'Yoga':
        return const Color(0xFFB565D8);
      case 'HIIT':
        return const Color(0xFFF9CA24);
      case 'CrossFit':
        return const Color(0xFF6C5CE7);
      case 'Natation':
        return const Color(0xFF00B894);
      case 'Course':
        return const Color(0xFFE17055);
      case 'Cyclisme':
        return const Color(0xFF0984E3);
      default:
        return const Color(0xFFC7F000);
    }
  }

  static IconData getWorkoutIcon(String type) {
    switch (type) {
      case 'Cardio':
        return Icons.favorite;
      case 'Force':
        return Icons.fitness_center;
      case 'Étirement':
        return Icons.self_improvement;
      case 'Yoga':
        return Icons.spa;
      case 'HIIT':
        return Icons.local_fire_department;
      case 'CrossFit':
        return Icons.sports_gymnastics;
      case 'Natation':
        return Icons.pool;
      case 'Course':
        return Icons.directions_run;
      case 'Cyclisme':
        return Icons.directions_bike;
      default:
        return Icons.sports;
    }
  }
}