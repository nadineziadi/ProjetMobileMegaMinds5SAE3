import 'workout.dart';

class Program {
  final int? id;
  final String name;
  final String description;
  final String goal; // 'fat_loss', 'strength', 'cardio'
  final int durationWeeks;
  final List<Workout> workouts;
  final String difficulty;
  final String? equipment;

  Program({
    this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.durationWeeks,
    required this.workouts,
    required this.difficulty,
    this.equipment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'goal': goal,
      'duration_weeks': durationWeeks,
      'difficulty': difficulty,
      'equipment': equipment,
    };
  }

  factory Program.fromMap(Map<String, dynamic> map, List<Workout> workouts) {
    return Program(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      goal: map['goal'],
      durationWeeks: map['duration_weeks'],
      workouts: workouts,
      difficulty: map['difficulty'],
      equipment: map['equipment'],
    );
  }
}