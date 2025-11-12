class Exercise {
  final int? id;
  final String name;
  final String description;
  final int sets;
  final int reps;
  final String? equipment;
  final String difficulty; // 'easy', 'medium', 'hard'

  Exercise({
    this.id,
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    this.equipment,
    required this.difficulty,
  });

  // Convert Exercise to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sets': sets,
      'reps': reps,
      'equipment': equipment,
      'difficulty': difficulty,
    };
  }

  // Convert Map to Exercise
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      sets: map['sets'],
      reps: map['reps'],
      equipment: map['equipment'],
      difficulty: map['difficulty'],
    );
  }
}