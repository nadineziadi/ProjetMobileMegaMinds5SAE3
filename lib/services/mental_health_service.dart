// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/mental_health_models.dart';

// class MentalHealthService {
//   // ZenQuotes API pour les citations inspirantes
//   static const String _quotesApiUrl = 'https://zenquotes.io/api/quotes';

//   /// Récupère une citation inspirante depuis ZenQuotes API
//   Future<Quote?> fetchDailyQuote() async {
//     try {
//       final response = await http.get(Uri.parse(_quotesApiUrl));
      
//       if (response.statusCode == 200) {
//         final List<dynamic> quotes = json.decode(response.body);
//         if (quotes.isNotEmpty) {
//           final quoteData = quotes[0];
//           return Quote(
//             id: DateTime.now().toString(),
//             text: quoteData['q'],
//             author: quoteData['a'],
//           );
//         }
//       }
//       return null;
//     } catch (e) {
//       print('Error fetching quote: $e');
//       return null;
//     }
//   }

//   /// Sauvegarde une entrée d'humeur localement
//   Future<bool> saveMoodEntry(MoodEntry entry) async {
//     try {
//       // TODO: Implémenter la sauvegarde avec sqflite ou shared_preferences
//       // Pour l'instant, simulation
//       await Future.delayed(const Duration(milliseconds: 500));
//       return true;
//     } catch (e) {
//       print('Error saving mood entry: $e');
//       return false;
//     }
//   }

//   /// Récupère l'historique des humeurs
//   Future<List<MoodEntry>> getMoodHistory({int days = 7}) async {
//     try {
//       // TODO: Implémenter la récupération depuis la base de données locale
//       // Pour l'instant, retour de données de test
//       return _generateMockMoodHistory(days);
//     } catch (e) {
//       print('Error fetching mood history: $e');
//       return [];
//     }
//   }

//   /// Récupère les statistiques de santé mentale
//   Future<MentalHealthStats?> getMentalHealthStats() async {
//     try {
//       // TODO: Intégration avec Google Fit API ou Health Connect
//       // Pour l'instant, retour de données de test
//       return MentalHealthStats(
//         mentalHealthScore: 92.54,
//         caloriesBurned: 470,
//         nutritionCalories: 618,
//         sleepDuration: const Duration(hours: 8, minutes: 30),
//         heartRate: 70,
//         date: DateTime.now(),
//       );
//     } catch (e) {
//       print('Error fetching mental health stats: $e');
//       return null;
//     }
//   }

//   /// Récupère les exercices de relaxation
//   Future<List<RelaxationExercise>> getRelaxationExercises() async {
//     try {
//       // TODO: Implémenter la récupération depuis une API ou base de données
//       return _generateMockExercises();
//     } catch (e) {
//       print('Error fetching relaxation exercises: $e');
//       return [];
//     }
//   }

//   /// Analyse l'humeur et suggère des exercices
//   RelaxationExercise? recommendExercise(String mood) {
//     final exercises = _generateMockExercises();
    
//     switch (mood.toLowerCase()) {
//       case 'stressed':
//         return exercises.firstWhere(
//           (e) => e.category == 'breathing',
//           orElse: () => exercises.first,
//         );
//       case 'tired':
//         return exercises.firstWhere(
//           (e) => e.category == 'meditation',
//           orElse: () => exercises.first,
//         );
//       case 'motivated':
//         return exercises.firstWhere(
//           (e) => e.category == 'yoga',
//           orElse: () => exercises.first,
//         );
//       default:
//         return exercises.first;
//     }
//   }

//   // Méthodes privées pour générer des données de test
//   List<MoodEntry> _generateMockMoodHistory(int days) {
//     final now = DateTime.now();
//     final moods = ['happy', 'stressed', 'tired', 'motivated', 'neutral'];
    
//     return List.generate(days, (index) {
//       return MoodEntry(
//         id: 'mood_$index',
//         date: now.subtract(Duration(days: days - index)),
//         mood: moods[index % moods.length],
//         intensity: 3 + (index % 3),
//         note: index % 2 == 0 ? 'Feeling good today!' : null,
//       );
//     });
//   }

//   List<RelaxationExercise> _generateMockExercises() {
//     return [
//       RelaxationExercise(
//         id: 'ex_1',
//         title: 'Deep Breathing',
//         subtitle: 'Calm your mind',
//         category: 'breathing',
//         durationMinutes: 5,
//       ),
//       RelaxationExercise(
//         id: 'ex_2',
//         title: 'Body Scan',
//         subtitle: 'Release tension',
//         category: 'meditation',
//         durationMinutes: 10,
//       ),
//       RelaxationExercise(
//         id: 'ex_3',
//         title: 'Guided Meditation',
//         subtitle: 'Inner peace',
//         category: 'meditation',
//         durationMinutes: 15,
//       ),
//       RelaxationExercise(
//         id: 'ex_4',
//         title: 'Peaceful Music',
//         subtitle: 'Relax your soul',
//         category: 'music',
//         durationMinutes: 20,
//       ),
//       RelaxationExercise(
//         id: 'ex_5',
//         title: 'Morning Yoga',
//         subtitle: 'Start your day right',
//         category: 'yoga',
//         durationMinutes: 15,
//       ),
//     ];
//   }
// }
// lib/services/mental_health_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/mental_health_models.dart';
import 'database_helper.dart';

class MentalHealthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ========== API EXTERNE - ZenQuotes ==========
  static const String _zenQuotesApi = 'https://zenquotes.io/api/quotes';
  static const String _zenQuotesTodayApi = 'https://zenquotes.io/api/today';

  /// Récupère une citation inspirante depuis ZenQuotes API
  Future<Quote?> fetchDailyQuote() async {
    try {
      // Essayer d'abord l'API "today"
      var response = await http.get(Uri.parse(_zenQuotesTodayApi));
      
      if (response.statusCode != 200) {
        // Si échec, utiliser l'API quotes générale
        response = await http.get(Uri.parse(_zenQuotesApi));
      }

      if (response.statusCode == 200) {
        final List<dynamic> quotes = json.decode(response.body);
        if (quotes.isNotEmpty) {
          final quoteData = quotes[0];
          final quote = Quote(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: quoteData['q'] ?? quoteData['quote'] ?? 'Stay positive!',
            author: quoteData['a'] ?? quoteData['author'] ?? 'Anonymous',
            fetchedAt: DateTime.now(),
          );

          // Sauvegarder dans la base de données
          await _dbHelper.createQuote(quote);
          return quote;
        }
      }

      // Si l'API échoue, utiliser une citation locale
      return _getFallbackQuote();
    } catch (e) {
      print('Error fetching quote from API: $e');
      return _getFallbackQuote();
    }
  }

  /// Citation de secours si l'API échoue
  Quote _getFallbackQuote() {
    final fallbackQuotes = [
      {
        'text': 'Your mental health is everything. Prioritize it.',
        'author': 'Unknown'
      },
      {
        'text': 'Taking care of yourself doesn\'t mean me first, it means me too.',
        'author': 'L.R. Knost'
      },
      {
        'text': 'Be patient with yourself. Self-growth is tender; it\'s holy ground.',
        'author': 'Stephen Covey'
      },
      {
        'text': 'You are enough just as you are.',
        'author': 'Meghan Markle'
      },
      {
        'text': 'Mental health is not a destination, but a process.',
        'author': 'Unknown'
      },
    ];

    final random = Random();
    final selected = fallbackQuotes[random.nextInt(fallbackQuotes.length)];

    return Quote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: selected['text']!,
      author: selected['author']!,
      fetchedAt: DateTime.now(),
    );
  }

  /// Récupère la citation du jour depuis la DB ou l'API
  Future<Quote> getTodayQuote() async {
    // Vérifier si on a déjà une citation d'aujourd'hui
    final latestQuote = await _dbHelper.getLatestQuote();
    
    if (latestQuote != null && latestQuote.fetchedAt != null) {
      final today = DateTime.now();
      final quoteDate = latestQuote.fetchedAt!;
      
      if (quoteDate.year == today.year &&
          quoteDate.month == today.month &&
          quoteDate.day == today.day) {
        return latestQuote;
      }
    }

    // Sinon, récupérer une nouvelle citation
    final newQuote = await fetchDailyQuote();
    return newQuote ?? _getFallbackQuote();
  }

  // ========== MOOD TRACKING ==========

  /// Sauvegarde une entrée d'humeur
  Future<bool> saveMoodEntry(MoodEntry entry) async {
    try {
      await _dbHelper.createMoodEntry(entry);
      
      // Générer automatiquement des stats de santé mentale
      await _generateMentalHealthStats();
      
      return true;
    } catch (e) {
      print('Error saving mood entry: $e');
      return false;
    }
  }

  /// Récupère l'historique des humeurs
  Future<List<MoodEntry>> getMoodHistory({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      var entries = await _dbHelper.getMoodEntriesByDateRange(startDate, endDate);
      
      // Si aucune donnée, générer des données de test
      if (entries.isEmpty) {
        entries = await _generateMockMoodHistory(days);
      }
      
      return entries;
    } catch (e) {
      print('Error fetching mood history: $e');
      return [];
    }
  }

  /// Récupère les statistiques d'humeur
  Future<Map<String, dynamic>> getMoodStatistics({int days = 30}) async {
    final entries = await getMoodHistory(days: days);
    
    if (entries.isEmpty) {
      return {
        'averageIntensity': 3.0,
        'mostFrequentMood': 'neutral',
        'totalEntries': 0,
        'moodDistribution': {},
      };
    }

    // Calculer la moyenne d'intensité
    final avgIntensity = entries.map((e) => e.intensity).reduce((a, b) => a + b) / entries.length;

    // Compter les humeurs
    final moodCounts = <String, int>{};
    for (var entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    // Trouver l'humeur la plus fréquente
    String mostFrequentMood = 'neutral';
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentMood = mood;
      }
    });

    return {
      'averageIntensity': avgIntensity,
      'mostFrequentMood': mostFrequentMood,
      'totalEntries': entries.length,
      'moodDistribution': moodCounts,
    };
  }

  // ========== MENTAL HEALTH STATS ==========

  /// Récupère les statistiques de santé mentale
  Future<MentalHealthStats> getMentalHealthStats() async {
    try {
      var stats = await _dbHelper.getLatestMentalHealthStats();
      
      // Si aucune stat, en générer une
      if (stats == null) {
        stats = await _generateMentalHealthStats();
      }
      
      return stats;
    } catch (e) {
      print('Error fetching mental health stats: $e');
      return MentalHealthStats(
        mentalHealthScore: 85.0,
        caloriesBurned: 400,
        nutritionCalories: 600,
        sleepDuration: const Duration(hours: 8),
        heartRate: 72,
        date: DateTime.now(),
      );
    }
  }

  /// Génère des statistiques basées sur l'humeur récente
  Future<MentalHealthStats> _generateMentalHealthStats() async {
    final recentMoods = await getMoodHistory(days: 7);
    
    double mentalScore = 85.0;
    if (recentMoods.isNotEmpty) {
      final avgIntensity = recentMoods.map((e) => e.intensity).reduce((a, b) => a + b) / recentMoods.length;
      mentalScore = (avgIntensity / 5) * 100;
    }

    final random = Random();
    final stats = MentalHealthStats(
      mentalHealthScore: mentalScore,
      caloriesBurned: 350 + random.nextInt(200),
      nutritionCalories: 500 + random.nextInt(300),
      sleepDuration: Duration(
        hours: 7 + random.nextInt(3),
        minutes: random.nextInt(60),
      ),
      heartRate: 60 + random.nextInt(20),
      date: DateTime.now(),
    );

    await _dbHelper.createMentalHealthStats(stats);
    return stats;
  }

  /// Récupère les stats sur une période
  Future<List<MentalHealthStats>> getStatsHistory({
    required String period, // 'daily', 'weekly', 'monthly'
  }) async {
    final endDate = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'daily':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case 'weekly':
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      case 'monthly':
        startDate = endDate.subtract(const Duration(days: 90));
        break;
      default:
        startDate = endDate.subtract(const Duration(days: 7));
    }

    var stats = await _dbHelper.getMentalHealthStatsByDateRange(startDate, endDate);
    
    // Si pas de données, générer des données de test
    if (stats.isEmpty) {
      stats = await _generateMockStats(period);
    }
    
    return stats;
  }

  // ========== RELAXATION EXERCISES ==========

  /// Récupère tous les exercices de relaxation
  Future<List<RelaxationExercise>> getRelaxationExercises({String? category}) async {
    try {
      if (category != null) {
        return await _dbHelper.getExercisesByCategory(category);
      }
      return await _dbHelper.getAllExercises();
    } catch (e) {
      print('Error fetching relaxation exercises: $e');
      return [];
    }
  }

  /// Recommande un exercice basé sur l'humeur
  Future<RelaxationExercise?> recommendExercise(String mood) async {
    final exercises = await getRelaxationExercises();
    
    if (exercises.isEmpty) return null;

    switch (mood.toLowerCase()) {
      case 'stressed':
      case 'anxious':
        return exercises.firstWhere(
          (e) => e.category == 'breathing',
          orElse: () => exercises.first,
        );
      case 'tired':
      case 'exhausted':
        return exercises.firstWhere(
          (e) => e.category == 'meditation',
          orElse: () => exercises.first,
        );
      case 'motivated':
      case 'energetic':
        return exercises.firstWhere(
          (e) => e.category == 'yoga',
          orElse: () => exercises.first,
        );
      case 'sad':
      case 'down':
        return exercises.firstWhere(
          (e) => e.category == 'music',
          orElse: () => exercises.first,
        );
      default:
        return exercises.first;
    }
  }

  /// Marque un exercice comme complété
  Future<bool> completeExercise(String exerciseId) async {
    try {
      await _dbHelper.markExerciseCompleted(exerciseId);
      return true;
    } catch (e) {
      print('Error completing exercise: $e');
      return false;
    }
  }

  // ========== WELLNESS HUB ==========

  /// Récupère les posts du Wellness Hub
  Future<List<WellnessPost>> getWellnessPosts({String? category}) async {
    try {
      return await _dbHelper.getAllPosts(category: category);
    } catch (e) {
      print('Error fetching wellness posts: $e');
      return [];
    }
  }

  /// Crée un nouveau post
  Future<bool> createWellnessPost(String content, String category) async {
    try {
      final post = WellnessPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'Me', // TODO: Remplacer par le vrai nom d'utilisateur
        content: content,
        createdAt: DateTime.now(),
        category: category,
      );

      await _dbHelper.createPost(post);
      return true;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  /// Toggle like sur un post
  Future<bool> togglePostLike(WellnessPost post) async {
    try {
      await _dbHelper.togglePostLike(
        post.id,
        !post.isLiked,
        post.likes,
      );
      return true;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // ========== DAILY TASKS ==========

  /// Récupère les tâches du jour
  Future<List<DailyTask>> getTodayTasks() async {
    try {
      return await _dbHelper.getTodayTasks();
    } catch (e) {
      print('Error fetching today tasks: $e');
      return [];
    }
  }

  /// Toggle completion d'une tâche
  Future<bool> toggleTaskCompletion(DailyTask task) async {
    try {
      await _dbHelper.toggleTaskCompletion(task.id, !task.isCompleted);
      return true;
    } catch (e) {
      print('Error toggling task: $e');
      return false;
    }
  }

  // ========== MOCK DATA GENERATORS ==========

  Future<List<MoodEntry>> _generateMockMoodHistory(int days) async {
    final moods = ['happy', 'stressed', 'tired', 'motivated', 'neutral', 'calm', 'excited'];
    final entries = <MoodEntry>[];
    final now = DateTime.now();
    final random = Random();

    for (int i = 0; i < days; i++) {
      final entry = MoodEntry(
        date: now.subtract(Duration(days: days - i)),
        mood: moods[random.nextInt(moods.length)],
        intensity: 2 + random.nextInt(4), // 2-5
        note: i % 3 == 0 ? 'Feeling good today!' : null,
      );
      
      await _dbHelper.createMoodEntry(entry);
      entries.add(entry);
    }

    return entries;
  }

  Future<List<MentalHealthStats>> _generateMockStats(String period) async {
    final stats = <MentalHealthStats>[];
    final now = DateTime.now();
    final random = Random();
    
    int days;
    switch (period) {
      case 'daily':
        days = 7;
        break;
      case 'weekly':
        days = 4;
        break;
      case 'monthly':
        days = 12;
        break;
      default:
        days = 7;
    }

    for (int i = 0; i < days; i++) {
      final stat = MentalHealthStats(
        mentalHealthScore: 80 + random.nextInt(20).toDouble(),
        caloriesBurned: 300 + random.nextInt(300),
        nutritionCalories: 500 + random.nextInt(400),
        sleepDuration: Duration(
          hours: 6 + random.nextInt(4),
          minutes: random.nextInt(60),
        ),
        heartRate: 60 + random.nextInt(25),
        date: now.subtract(Duration(days: days - i)),
      );
      
      await _dbHelper.createMentalHealthStats(stat);
      stats.add(stat);
    }

    return stats;
  }

  // ========== UTILITY ==========

  /// Réinitialise toutes les données (pour testing)
  Future<void> resetAllData() async {
    await _dbHelper.clearAllData();
  }
}