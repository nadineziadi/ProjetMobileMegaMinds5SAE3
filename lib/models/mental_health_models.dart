// class MoodEntry {
//   final String id;
//   final DateTime date;
//   final String mood; // 'happy', 'stressed', 'tired', 'motivated', 'neutral'
//   final String? note;
//   final int intensity; // 1-5

//   MoodEntry({
//     required this.id,
//     required this.date,
//     required this.mood,
//     this.note,
//     required this.intensity,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'date': date.toIso8601String(),
//       'mood': mood,
//       'note': note,
//       'intensity': intensity,
//     };
//   }

//   factory MoodEntry.fromJson(Map<String, dynamic> json) {
//     return MoodEntry(
//       id: json['id'],
//       date: DateTime.parse(json['date']),
//       mood: json['mood'],
//       note: json['note'],
//       intensity: json['intensity'],
//     );
//   }
// }

// class RelaxationExercise {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String category; // 'breathing', 'meditation', 'music', 'yoga'
//   final int durationMinutes;
//   final String? audioUrl;
//   final String? imageUrl;

//   RelaxationExercise({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.category,
//     required this.durationMinutes,
//     this.audioUrl,
//     this.imageUrl,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'subtitle': subtitle,
//       'category': category,
//       'durationMinutes': durationMinutes,
//       'audioUrl': audioUrl,
//       'imageUrl': imageUrl,
//     };
//   }

//   factory RelaxationExercise.fromJson(Map<String, dynamic> json) {
//     return RelaxationExercise(
//       id: json['id'],
//       title: json['title'],
//       subtitle: json['subtitle'],
//       category: json['category'],
//       durationMinutes: json['durationMinutes'],
//       audioUrl: json['audioUrl'],
//       imageUrl: json['imageUrl'],
//     );
//   }
// }

// class Quote {
//   final String id;
//   final String text;
//   final String author;
//   final String? category;

//   Quote({
//     required this.id,
//     required this.text,
//     required this.author,
//     this.category,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'text': text,
//       'author': author,
//       'category': category,
//     };
//   }

//   factory Quote.fromJson(Map<String, dynamic> json) {
//     return Quote(
//       id: json['id'],
//       text: json['text'],
//       author: json['author'],
//       category: json['category'],
//     );
//   }
// }

// class WellnessPost {
//   final String id;
//   final String authorName;
//   final String authorAvatar;
//   final String content;
//   final DateTime timestamp;
//   final int likes;
//   final int comments;
//   final List<String> tags;

//   WellnessPost({
//     required this.id,
//     required this.authorName,
//     required this.authorAvatar,
//     required this.content,
//     required this.timestamp,
//     required this.likes,
//     required this.comments,
//     required this.tags,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'authorName': authorName,
//       'authorAvatar': authorAvatar,
//       'content': content,
//       'timestamp': timestamp.toIso8601String(),
//       'likes': likes,
//       'comments': comments,
//       'tags': tags,
//     };
//   }

//   factory WellnessPost.fromJson(Map<String, dynamic> json) {
//     return WellnessPost(
//       id: json['id'],
//       authorName: json['authorName'],
//       authorAvatar: json['authorAvatar'],
//       content: json['content'],
//       timestamp: DateTime.parse(json['timestamp']),
//       likes: json['likes'],
//       comments: json['comments'],
//       tags: List<String>.from(json['tags']),
//     );
//   }
// }

// class MentalHealthStats {
//   final double mentalHealthScore;
//   final int caloriesBurned;
//   final int nutritionCalories;
//   final Duration sleepDuration;
//   final int heartRate;
//   final DateTime date;

//   MentalHealthStats({
//     required this.mentalHealthScore,
//     required this.caloriesBurned,
//     required this.nutritionCalories,
//     required this.sleepDuration,
//     required this.heartRate,
//     required this.date,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'mentalHealthScore': mentalHealthScore,
//       'caloriesBurned': caloriesBurned,
//       'nutritionCalories': nutritionCalories,
//       'sleepDurationMinutes': sleepDuration.inMinutes,
//       'heartRate': heartRate,
//       'date': date.toIso8601String(),
//     };
//   }

//   factory MentalHealthStats.fromJson(Map<String, dynamic> json) {
//     return MentalHealthStats(
//       mentalHealthScore: json['mentalHealthScore'],
//       caloriesBurned: json['caloriesBurned'],
//       nutritionCalories: json['nutritionCalories'],
//       sleepDuration: Duration(minutes: json['sleepDurationMinutes']),
//       heartRate: json['heartRate'],
//       date: DateTime.parse(json['date']),
//     );
//   }
// }
// lib/models/mental_health_models.dart

/// Modèle pour les entrées d'humeur
class MoodEntry {
  final String? id;
  final DateTime date;
  final String mood;
  final int intensity; // 1-5
  final String? note;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.intensity,
    this.note,
  });

  // Conversion vers Map pour SQFlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'intensity': intensity,
      'note': note,
    };
  }

  // Création depuis Map
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id']?.toString(),
      date: DateTime.parse(map['date']),
      mood: map['mood'],
      intensity: map['intensity'],
      note: map['note'],
    );
  }

  // Conversion JSON
  Map<String, dynamic> toJson() => toMap();
  
  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry.fromMap(json);

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    String? mood,
    int? intensity,
    String? note,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
    );
  }
}

/// Modèle pour les citations inspirantes
class Quote {
  final String id;
  final String text;
  final String author;
  final DateTime? fetchedAt;
  final bool isFavorite;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    this.fetchedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'fetchedAt': fetchedAt?.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'],
      text: map['text'],
      author: map['author'],
      fetchedAt: map['fetchedAt'] != null ? DateTime.parse(map['fetchedAt']) : null,
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Quote.fromJson(Map<String, dynamic> json) => Quote.fromMap(json);

  Quote copyWith({
    String? id,
    String? text,
    String? author,
    DateTime? fetchedAt,
    bool? isFavorite,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Modèle pour les statistiques de santé mentale
class MentalHealthStats {
  final String? id;
  final double mentalHealthScore;
  final int caloriesBurned;
  final int nutritionCalories;
  final Duration sleepDuration;
  final int heartRate;
  final DateTime date;

  MentalHealthStats({
    this.id,
    required this.mentalHealthScore,
    required this.caloriesBurned,
    required this.nutritionCalories,
    required this.sleepDuration,
    required this.heartRate,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mentalHealthScore': mentalHealthScore,
      'caloriesBurned': caloriesBurned,
      'nutritionCalories': nutritionCalories,
      'sleepDurationMinutes': sleepDuration.inMinutes,
      'heartRate': heartRate,
      'date': date.toIso8601String(),
    };
  }

  factory MentalHealthStats.fromMap(Map<String, dynamic> map) {
    return MentalHealthStats(
      id: map['id']?.toString(),
      mentalHealthScore: map['mentalHealthScore'],
      caloriesBurned: map['caloriesBurned'],
      nutritionCalories: map['nutritionCalories'],
      sleepDuration: Duration(minutes: map['sleepDurationMinutes']),
      heartRate: map['heartRate'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory MentalHealthStats.fromJson(Map<String, dynamic> json) => MentalHealthStats.fromMap(json);

  String get formattedSleepDuration {
    int hours = sleepDuration.inHours;
    int minutes = sleepDuration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

/// Modèle pour les exercices de relaxation
class RelaxationExercise {
  final String id;
  final String title;
  final String subtitle;
  final String category; // breathing, meditation, music, yoga
  final int durationMinutes;
  final String? audioUrl;
  final String? imageUrl;
  final bool isCompleted;
  final DateTime? lastCompletedAt;

  RelaxationExercise({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.durationMinutes,
    this.audioUrl,
    this.imageUrl,
    this.isCompleted = false,
    this.lastCompletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'durationMinutes': durationMinutes,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted ? 1 : 0,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
    };
  }

  factory RelaxationExercise.fromMap(Map<String, dynamic> map) {
    return RelaxationExercise(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      category: map['category'],
      durationMinutes: map['durationMinutes'],
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      isCompleted: map['isCompleted'] == 1,
      lastCompletedAt: map['lastCompletedAt'] != null 
          ? DateTime.parse(map['lastCompletedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory RelaxationExercise.fromJson(Map<String, dynamic> json) => RelaxationExercise.fromMap(json);

  RelaxationExercise copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    int? durationMinutes,
    String? audioUrl,
    String? imageUrl,
    bool? isCompleted,
    DateTime? lastCompletedAt,
  }) {
    return RelaxationExercise(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }
}

/// Modèle pour les posts du Wellness Hub
class WellnessPost {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String category; // therapy, relationship, self-care, work
  final bool isLiked;

  WellnessPost({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    required this.category,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'category': category,
      'isLiked': isLiked ? 1 : 0,
    };
  }

  factory WellnessPost.fromMap(Map<String, dynamic> map) {
    return WellnessPost(
      id: map['id'],
      author: map['author'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: map['likes'],
      comments: map['comments'],
      category: map['category'],
      isLiked: map['isLiked'] == 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory WellnessPost.fromJson(Map<String, dynamic> json) => WellnessPost.fromMap(json);

  WellnessPost copyWith({
    String? id,
    String? author,
    String? content,
    DateTime? createdAt,
    int? likes,
    int? comments,
    String? category,
    bool? isLiked,
  }) {
    return WellnessPost(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      category: category ?? this.category,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min ago';
    } else {
      return 'just now';
    }
  }
}

/// Modèle pour les tâches du jour
class DailyTask {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isCompleted;
  final String type; // meetup, meditation, exercise, etc.

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isCompleted = false,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'type': type,
    };
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      scheduledTime: DateTime.parse(map['scheduledTime']),
      isCompleted: map['isCompleted'] == 1,
      type: map['type'],
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask.fromMap(json);

  DailyTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isCompleted,
    String? type,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
    );
  }
}