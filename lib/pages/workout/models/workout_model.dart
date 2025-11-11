class Workout {
  final int? id;
  final String name;
  final int duration; // in minutes
  final String type; // cardio, force, étirement, etc.
  final DateTime date;
  final int? caloriesBurned;
  final String? notes;
  final String? youtubeVideoId;
  

  Workout({
    this.id,
    required this.name,
    required this.duration,
    required this.type,
    required this.date,
    this.caloriesBurned,
    this.notes,
    this.youtubeVideoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'type': type,
      'date': date.toIso8601String(),
      'caloriesBurned': caloriesBurned,
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      duration: map['duration'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      caloriesBurned: map['caloriesBurned'],
      notes: map['notes'],
    );
  }

  Workout copyWith({
    int? id,
    String? name,
    int? duration,
    String? type,
    DateTime? date,
    int? caloriesBurned,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      date: date ?? this.date,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
    );
  }
}
