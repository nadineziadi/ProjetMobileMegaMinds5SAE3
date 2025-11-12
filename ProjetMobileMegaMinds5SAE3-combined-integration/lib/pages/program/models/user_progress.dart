class WorkoutLog {
  final int? id;
  final int workoutId;
  final DateTime date;
  final bool completed;
  final String? notes;
  final int? fatigueLevel; // 1-5

  WorkoutLog({
    this.id,
    required this.workoutId,
    required this.date,
    required this.completed,
    this.notes,
    this.fatigueLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'date': date.toIso8601String(),
      'completed': completed ? 1 : 0,
      'notes': notes,
      'fatigue_level': fatigueLevel,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'],
      workoutId: map['workout_id'],
      date: DateTime.parse(map['date']),
      completed: map['completed'] == 1,
      notes: map['notes'],
      fatigueLevel: map['fatigue_level'],
    );
  }
}