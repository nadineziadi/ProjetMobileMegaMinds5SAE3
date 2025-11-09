import 'exercise.dart';

class Workout {
  final int? id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int durationMinutes;
  final String difficulty;
  final bool isRestDay;

  Workout({
    this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.durationMinutes,
    required this.difficulty,
    this.isRestDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration_minutes': durationMinutes,
      'difficulty': difficulty,
      'is_rest_day': isRestDay ? 1 : 0,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, List<Exercise> exercises) {
    return Workout(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      exercises: exercises,
      durationMinutes: map['duration_minutes'],
      difficulty: map['difficulty'],
      isRestDay: map['is_rest_day'] == 1,
    );
  }
}