// lib/models/exercise_library.dart
class ExerciseLibrary {
  final int? id;
  final String name;
  final String description;
  final String category; // 'chest', 'back', 'legs', 'shoulders', 'arms', 'core', 'cardio'
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final List<String> muscleGroups; // ['pectorals', 'triceps']
  final List<String> equipment; // ['barbell', 'dumbbell', 'bodyweight', 'machine', 'cable']
  final String? videoUrl; // YouTube URL or local asset path
  final String? thumbnailUrl;
  final List<String> instructions;
  final List<String> tips;
  final List<String> commonMistakes;
  final bool isFavorite;
  final DateTime createdAt;

  ExerciseLibrary({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.muscleGroups,
    required this.equipment,
    this.videoUrl,
    this.thumbnailUrl,
    required this.instructions,
    this.tips = const [],
    this.commonMistakes = const [],
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'muscleGroups': muscleGroups.join(','),
      'equipment': equipment.join(','),
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'instructions': instructions.join('|'),
      'tips': tips.join('|'),
      'commonMistakes': commonMistakes.join('|'),
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory ExerciseLibrary.fromMap(Map<String, dynamic> map) {
    return ExerciseLibrary(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      difficulty: map['difficulty'],
      muscleGroups: (map['muscleGroups'] as String).split(','),
      equipment: (map['equipment'] as String).split(','),
      videoUrl: map['videoUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      instructions: (map['instructions'] as String).split('|'),
      tips: map['tips'] != null && (map['tips'] as String).isNotEmpty
          ? (map['tips'] as String).split('|')
          : [],
      commonMistakes: map['commonMistakes'] != null &&
              (map['commonMistakes'] as String).isNotEmpty
          ? (map['commonMistakes'] as String).split('|')
          : [],
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  ExerciseLibrary copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? difficulty,
    List<String>? muscleGroups,
    List<String>? equipment,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? instructions,
    List<String>? tips,
    List<String>? commonMistakes,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return ExerciseLibrary(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Helper class for filtering
class ExerciseFilter {
  final String? category;
  final String? difficulty;
  final List<String>? equipment;
  final List<String>? muscleGroups;
  final bool? favoritesOnly;
  final String? searchQuery;

  ExerciseFilter({
    this.category,
    this.difficulty,
    this.equipment,
    this.muscleGroups,
    this.favoritesOnly,
    this.searchQuery,
  });

  ExerciseFilter copyWith({
    String? category,
    String? difficulty,
    List<String>? equipment,
    List<String>? muscleGroups,
    bool? favoritesOnly,
    String? searchQuery,
  }) {
    return ExerciseFilter(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      category != null ||
      difficulty != null ||
      (equipment != null && equipment!.isNotEmpty) ||
      (muscleGroups != null && muscleGroups!.isNotEmpty) ||
      (favoritesOnly ?? false);
}