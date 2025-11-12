// lib/services/mental_health_service.dart
// ⚠️ VERSION AVEC SSL BYPASS - POUR DÉMO UNIQUEMENT !

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/mental_health_models.dart';
import 'database_helper.dart';

class MentalHealthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ========== API EXTERNE - QUOTABLE ==========
  static const String _quotableApi = 'https://api.quotable.io/random?tags=inspirational';

  /// ⚠️ BYPASS SSL - POUR DÉMO UNIQUEMENT
  static HttpClient? _httpClient;
  
  static HttpClient _getHttpClient() {
    if (_httpClient == null) {
      _httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // ⚠️ ACCEPTER TOUS LES CERTIFICATS - NE JAMAIS FAIRE EN PRODUCTION !
          print('⚠️ SSL verification bypassed for: $host');
          return true;
        };
    }
    return _httpClient!;
  }

  /// Récupère une citation inspirante depuis Quotable API
  Future<Quote?> fetchDailyQuote() async {
    try {
      print('🌐 Fetching quote from Quotable API...');
      
      // Méthode 1: Avec bypass SSL
      final client = _getHttpClient();
      final request = await client.getUrl(Uri.parse(_quotableApi));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        
        print('✅ Quote fetched successfully: "${data['content']}"');

        final quote = Quote(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: data['content'] ?? 'Stay positive!',
          author: data['author'] ?? 'Anonymous',
          fetchedAt: DateTime.now(),
        );

        // Sauvegarder dans la base de données
        await _dbHelper.createQuote(quote);
        return quote;
      } else {
        print('⚠️ API returned status ${response.statusCode}');
      }

      return _getFallbackQuote();
    } catch (e) {
      print('❌ Error fetching quote from API: $e');
      return _getFallbackQuote();
    }
  }

  /// Citation de secours si l'API échoue
  Quote _getFallbackQuote() {
    print('📝 Using fallback quote...');
    
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
      {
        'text': 'It\'s okay to not be okay. What\'s important is that you\'re trying.',
        'author': 'Unknown'
      },
      {
        'text': 'Healing takes time, and asking for help is a courageous step.',
        'author': 'Mariska Hargitay'
      },
      {
        'text': 'You don\'t have to control your thoughts. You just have to stop letting them control you.',
        'author': 'Dan Millman'
      },
      {
        'text': 'Self-care is how you take your power back.',
        'author': 'Lalah Delia'
      },
      {
        'text': 'There is hope, even when your brain tells you there isn\'t.',
        'author': 'John Green'
      },
    ];

    final random = Random();
    final selected = fallbackQuotes[random.nextInt(fallbackQuotes.length)];

    final quote = Quote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: selected['text']!,
      author: selected['author']!,
      fetchedAt: DateTime.now(),
    );

    print('✅ Fallback quote: "${quote.text}" - ${quote.author}');
    return quote;
  }

  /// Récupère la citation du jour depuis la DB ou l'API
  Future<Quote> getTodayQuote() async {
    print('🔍 Checking for today\'s quote in database...');
    
    final latestQuote = await _dbHelper.getLatestQuote();

    if (latestQuote != null && latestQuote.fetchedAt != null) {
      final today = DateTime.now();
      final quoteDate = latestQuote.fetchedAt!;

      if (quoteDate.year == today.year &&
          quoteDate.month == today.month &&
          quoteDate.day == today.day) {
        print('✅ Found today\'s quote in cache');
        return latestQuote;
      }
    }

    print('🆕 Fetching new quote...');
    final newQuote = await fetchDailyQuote();
    return newQuote ?? _getFallbackQuote();
  }

  // ========== MOOD TRACKING ==========

  Future<bool> saveMoodEntry(MoodEntry entry) async {
    try {
      await _dbHelper.createMoodEntry(entry);
      await _generateMentalHealthStats();
      return true;
    } catch (e) {
      print('Error saving mood entry: $e');
      return false;
    }
  }

  Future<List<MoodEntry>> getMoodHistory({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      var entries = await _dbHelper.getMoodEntriesByDateRange(startDate, endDate);

      if (entries.isEmpty) {
        entries = await _generateMockMoodHistory(days);
      }
      return entries;
    } catch (e) {
      print('Error fetching mood history: $e');
      return [];
    }
  }

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

    final avgIntensity = entries.map((e) => e.intensity).reduce((a, b) => a + b) / entries.length;

    final moodCounts = <String, int>{};
    for (var entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

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

  Future<MentalHealthStats> getMentalHealthStats() async {
    try {
      var stats = await _dbHelper.getLatestMentalHealthStats();
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

  Future<MentalHealthStats> _generateMentalHealthStats() async {
    final recentMoods = await getMoodHistory(days: 7);
    double mentalScore = 85.0;
    if (recentMoods.isNotEmpty) {
      final avgIntensity =
          recentMoods.map((e) => e.intensity).reduce((a, b) => a + b) / recentMoods.length;
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

  Future<List<MentalHealthStats>> getStatsHistory({required String period}) async {
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

    if (stats.isEmpty) {
      stats = await _generateMockStats(period);
    }

    return stats;
  }

  // ========== RELAXATION EXERCISES ==========

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

  Future<RelaxationExercise?> recommendExercise(String mood) async {
    final exercises = await getRelaxationExercises();
    if (exercises.isEmpty) return null;

    switch (mood.toLowerCase()) {
      case 'stressed':
      case 'anxious':
        return exercises.firstWhere((e) => e.category == 'breathing', orElse: () => exercises.first);
      case 'tired':
      case 'exhausted':
        return exercises.firstWhere((e) => e.category == 'meditation', orElse: () => exercises.first);
      case 'motivated':
      case 'energetic':
        return exercises.firstWhere((e) => e.category == 'yoga', orElse: () => exercises.first);
      case 'sad':
      case 'down':
        return exercises.firstWhere((e) => e.category == 'music', orElse: () => exercises.first);
      default:
        return exercises.first;
    }
  }

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

  Future<List<WellnessPost>> getWellnessPosts({String? category}) async {
    try {
      return await _dbHelper.getAllPosts(category: category);
    } catch (e) {
      print('Error fetching wellness posts: $e');
      return [];
    }
  }

  Future<bool> createWellnessPost(String content, String category) async {
    try {
      final post = WellnessPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'Me',
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

  Future<bool> togglePostLike(WellnessPost post) async {
    try {
      await _dbHelper.togglePostLike(post.id, !post.isLiked, post.likes);
      return true;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // ========== DAILY TASKS ==========

  Future<List<DailyTask>> getTodayTasks() async {
    try {
      return await _dbHelper.getTodayTasks();
    } catch (e) {
      print('Error fetching today tasks: $e');
      return [];
    }
  }

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
        intensity: 2 + random.nextInt(4),
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

  Future<void> resetAllData() async {
    await _dbHelper.clearAllData();
  }
}