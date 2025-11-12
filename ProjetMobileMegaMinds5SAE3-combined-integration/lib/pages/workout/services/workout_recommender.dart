// lib/services/workout_recommender.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import 'workout_database.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class WorkoutRecommendation {
  final String type;
  final String title;
  final String description;
  final String motivationalMessage;
  final int suggestedDuration;
  final int estimatedCalories;
  final String reason;
  final double confidenceScore;

  WorkoutRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.motivationalMessage,
    required this.suggestedDuration,
    required this.estimatedCalories,
    required this.reason,
    required this.confidenceScore,
  });

  factory WorkoutRecommendation.fromJson(Map<String, dynamic> json) {
    return WorkoutRecommendation(
      type: json['type'] ?? 'Cardio',
      title: json['title'] ?? 'Entraînement recommandé',
      description: json['description'] ?? '',
      motivationalMessage: json['motivationalMessage'] ?? '💪 Allez, on y va !',
      suggestedDuration: json['suggestedDuration'] ?? 30,
      estimatedCalories: json['estimatedCalories'] ?? 200,
      reason: json['reason'] ?? 'Recommandation personnalisée',
      confidenceScore: (json['confidenceScore'] ?? 0.85).toDouble(),
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'motivationalMessage': motivationalMessage,
      'suggestedDuration': suggestedDuration,
      'estimatedCalories': estimatedCalories,
      'reason': reason,
      'confidenceScore': confidenceScore,
    };
  }

}

class WorkoutRecommender {
  static final WorkoutRecommender instance = WorkoutRecommender._internal();
  WorkoutRecommender._internal();

  // 🔑 Gemini API key
static const String _geminiApiKey = ApiKeys.GeminiAI;

  
  // Enable/disable AI
  static const bool _useAI = true;

  final List<String> _motivationalMessages = [
    "💪 C'est le moment de vous surpasser !",
    "🔥 Votre meilleure version vous attend !",
    "⚡ Transformez votre énergie en force !",
    "🌟 Chaque répétition vous rapproche de votre objectif !",
    "🚀 Poussez vos limites aujourd'hui !",
    "💎 La discipline d'aujourd'hui = Les résultats de demain !",
    "🏆 Champions in the making, let's go !",
    "✨ Votre corps peut tout, c'est votre esprit qu'il faut convaincre !",
    "🎯 Focus, effort, résultat - dans cet ordre !",
    "⭐ Soyez plus fort que vos excuses !",
  ];

  // Main method
  Future<WorkoutRecommendation> getRecommendation() async {
    final workouts = await WorkoutDatabase.instance.readAll();
    final prefs = await SharedPreferences.getInstance();

    if (_useAI) {
      try {
        final userContext = await _buildUserContext(workouts, prefs);
        final aiRecommendation = await _getGeminiRecommendation(userContext);
        print('✅ AI recommendation successful!');
        return aiRecommendation;
      } catch (e) {
        print('❌ AI failed, using smart fallback: $e');
        return _getSmartRecommendation(workouts, prefs);
      }
    } else {
      return _getSmartRecommendation(workouts, prefs);
    }
  }

  // 🤖 Gemini AI Recommendation
  Future<WorkoutRecommendation> _getGeminiRecommendation(
    Map<String, dynamic> userContext,
  ) async {
    final prompt = _buildAIPrompt(userContext);

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.6,
            'maxOutputTokens': 2500,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('==================== RAW GEMINI RESPONSE ====================');
        print(response.body);
        print('=============================================================');

        final aiText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (aiText == null || aiText.trim().isEmpty) {
          throw Exception("Empty AI response text");
        }

        print('==================== AI RAW RESPONSE ====================');
        print(aiText);
        print('=========================================================');

        final recommendation = _parseAIResponse(aiText);
        print('✅ Parsed AI Recommendation: ${recommendation.toJson()}');
        return recommendation;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            'Gemini API error: ${error['error']?['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Gemini API error: $e');
      rethrow;
    }
  }

  // 👇 EDITED PROMPT: only JSON, no extra text
  String _buildAIPrompt(Map<String, dynamic> context) {
    return '''
Tu es un coach fitness professionnel IA. 
Analyse les données suivantes et génère UNIQUEMENT un objet JSON valide (pas de texte supplémentaire, pas de code block Markdown).

Données utilisateur:
${jsonEncode(context)}

Réponds avec cette structure exacte:
{
  "type": "type d'entraînement (Cardio, Force, Yoga, etc.)",
  "title": "titre accrocheur en français",
  "description": "description de 2-3 phrases en français",
  "motivationalMessage": "message inspirant avec emoji en français",
  "suggestedDuration": nombre en minutes,
  "estimatedCalories": nombre,
  "reason": "brève explication du pourquoi en français",
  "confidenceScore": nombre entre 0 et 1
}
''';
  }

  WorkoutRecommendation _parseAIResponse(String aiResponse) {
    try {
      String cleanResponse = aiResponse.trim();
      cleanResponse =
          cleanResponse.replaceAll(RegExp(r'```(?:json)?|```', caseSensitive: false), '').trim();

      final jsonStart = cleanResponse.indexOf('{');
      final jsonEnd = cleanResponse.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('No valid JSON found');
      }

      final jsonString = cleanResponse.substring(jsonStart, jsonEnd);
      print('📦 Cleaned JSON: $jsonString');

      final json = jsonDecode(jsonString);
      return WorkoutRecommendation.fromJson(json);
    } catch (e) {
      print('❌ Failed to parse AI response: $e');
      print('📄 Full response was: $aiResponse');
      throw Exception('Invalid AI response format: $e');
    }
  }

  // All your fallback + helper functions are unchanged below 👇

  Future<Map<String, dynamic>> _buildUserContext(
    List<Workout> workouts,
    SharedPreferences prefs,
  ) async {
    final context = <String, dynamic>{};
    context['totalWorkouts'] = workouts.length;
    context['totalCaloriesBurned'] = prefs.getInt('total_calories_burned') ?? 0;
    context['currentStreak'] = prefs.getInt('workout_streak') ?? 0;
    final recentWorkouts = _getRecentWorkouts(workouts, days: 14);
    context['recentWorkoutsCount'] = recentWorkouts.length;

    if (workouts.isNotEmpty) {
      final lastWorkout = workouts.first;
      final daysSinceLastWorkout =
          DateTime.now().difference(lastWorkout.date).inDays;
      context['daysSinceLastWorkout'] = daysSinceLastWorkout;
      context['lastWorkoutType'] = lastWorkout.type;
    }

    final typeFrequency = _analyzeTypeFrequency(workouts);
    context['workoutTypeDistribution'] = typeFrequency;

    if (workouts.isNotEmpty) {
      context['averageDuration'] = _calculateAverageDuration(workouts);
      final totalCalories = workouts
          .where((w) => w.caloriesBurned != null)
          .fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));
      context['averageCalories'] =
          workouts.isNotEmpty ? (totalCalories / workouts.length).round() : 0;
    }

    if (recentWorkouts.length >= 2) {
      final recentTypes = recentWorkouts.map((w) => w.type).toList();
      context['recentWorkoutTypes'] = recentTypes;
      final highIntensity = recentTypes
          .where((t) => t == 'HIIT' || t == 'Force' || t == 'CrossFit')
          .length;
      context['recentHighIntensityCount'] = highIntensity;
    }
    return context;
  }

  // Fallback logic unchanged
  Future<WorkoutRecommendation> _getSmartRecommendation(
    List<Workout> workouts,
    SharedPreferences prefs,
  ) async {
    if (workouts.isEmpty) {
      return _getBeginnerRecommendation();
    }

    final typeFrequency = _analyzeTypeFrequency(workouts);
    final recentWorkouts = _getRecentWorkouts(workouts, days: 7);
    final lastWorkoutDate = workouts.isNotEmpty ? workouts.first.date : null;
    final daysSinceLastWorkout = lastWorkoutDate != null
        ? DateTime.now().difference(lastWorkoutDate).inDays
        : 999;
    final averageDuration = _calculateAverageDuration(workouts);
    final workoutStreak = prefs.getInt('workout_streak') ?? 0;

    if (daysSinceLastWorkout >= 3) {
      return _getComebackRecommendation(typeFrequency, averageDuration);
    }

    if (recentWorkouts.length >= 2) {
      final recentTypes = recentWorkouts.map((w) => w.type).toList();
      if (recentTypes.every((t) => t == 'Force' || t == 'HIIT')) {
        return _getRecoveryRecommendation(averageDuration);
      }
      if (recentTypes.every((t) => t == 'Cardio' || t == 'Course')) {
        return _getStrengthRecommendation(averageDuration);
      }
    }

    final leastPerformedType = _getLeastPerformedType(typeFrequency);
    return _getBalanceRecommendation(
        leastPerformedType, averageDuration, workoutStreak);
  }

  // --- all remaining helper methods unchanged ---
  WorkoutRecommendation _getBeginnerRecommendation() {
    return WorkoutRecommendation(
      type: 'Cardio',
      title: 'Démarrez en douceur',
      description:
          'Une séance de cardio légère pour commencer votre parcours fitness',
      motivationalMessage:
          '🌱 Chaque expert était autrefois un débutant. Votre voyage commence maintenant !',
      suggestedDuration: 20,
      estimatedCalories: 150,
      reason: 'Première séance - idéal pour débuter',
      confidenceScore: 0.95,
    );
  }

  WorkoutRecommendation _getComebackRecommendation(
    Map<String, int> typeFrequency,
    int avgDuration,
  ) {
    final favoriteType =
        typeFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return WorkoutRecommendation(
      type: favoriteType,
      title: 'Content de vous revoir !',
      description: 'Reprenez avec votre type d\'entraînement préféré',
      motivationalMessage:
          '💪 La meilleure façon de revenir ? Recommencer maintenant !',
      suggestedDuration: (avgDuration * 0.8).round(),
      estimatedCalories:
          _estimateCalories(favoriteType, (avgDuration * 0.8).round()),
      reason: 'Reprise après pause - intensité modérée',
      confidenceScore: 0.88,
    );
  }

  WorkoutRecommendation _getRecoveryRecommendation(int avgDuration) {
    final recoveryTypes = ['Yoga', 'Étirement'];
    final type = recoveryTypes[Random().nextInt(recoveryTypes.length)];

    return WorkoutRecommendation(
      type: type,
      title: 'Temps de récupération',
      description:
          'Vos muscles ont besoin de repos actif après vos entraînements intenses',
      motivationalMessage: '🧘 La récupération fait partie de la progression !',
      suggestedDuration: 30,
      estimatedCalories: _estimateCalories(type, 30),
      reason: 'Récupération après entraînements intenses',
      confidenceScore: 0.92,
    );
  }

  WorkoutRecommendation _getStrengthRecommendation(int avgDuration) {
    return WorkoutRecommendation(
      type: 'Force',
      title: 'Développez votre force',
      description: 'Équilibrez votre cardio avec un entraînement de force',
      motivationalMessage: '💪 Les muscles forts créent un corps résilient !',
      suggestedDuration: avgDuration,
      estimatedCalories: _estimateCalories('Force', avgDuration),
      reason: 'Équilibre cardio/force recommandé',
      confidenceScore: 0.85,
    );
  }

  WorkoutRecommendation _getBalanceRecommendation(
    String type,
    int avgDuration,
    int streak,
  ) {
    final motivational = streak >= 7
        ? '🔥 ${streak} jours de suite ! Vous êtes en feu !'
        : _motivationalMessages[Random().nextInt(_motivationalMessages.length)];

    return WorkoutRecommendation(
      type: type,
      title: 'Équilibrez votre routine',
      description: 'Variez vos entraînements pour progresser plus vite',
      motivationalMessage: motivational,
      suggestedDuration: avgDuration,
      estimatedCalories: _estimateCalories(type, avgDuration),
      reason: 'Type d\'entraînement peu pratiqué récemment',
      confidenceScore: 0.80,
    );
  }

  String _getLeastPerformedType(Map<String, int> typeFrequency) {
    final allTypes = ['Cardio', 'Force', 'Yoga', 'HIIT', 'Étirement'];

    for (var type in allTypes) {
      if (!typeFrequency.containsKey(type)) return type;
    }

    return typeFrequency.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  Map<String, int> _analyzeTypeFrequency(List<Workout> workouts) {
    final frequency = <String, int>{};
    for (var workout in workouts) {
      frequency[workout.type] = (frequency[workout.type] ?? 0) + 1;
    }
    return frequency;
  }

  List<Workout> _getRecentWorkouts(List<Workout> workouts, {required int days}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return workouts.where((w) => w.date.isAfter(cutoffDate)).toList();
  }

  int _calculateAverageDuration(List<Workout> workouts) {
    if (workouts.isEmpty) return 30;
    final total = workouts.fold<int>(0, (sum, w) => sum + w.duration);
    return (total / workouts.length).round();
  }

  int _estimateCalories(String type, int duration) {
    final caloriesPerMinute = {
      'Cardio': 8,
      'Force': 6,
      'HIIT': 12,
      'Course': 10,
      'Cyclisme': 9,
      'Natation': 11,
      'CrossFit': 10,
      'Yoga': 3,
      'Étirement': 2,
    };
    return (caloriesPerMinute[type] ?? 7) * duration;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWorkoutDate = prefs.getString('last_workout_date');
    final today = DateTime.now();

    if (lastWorkoutDate != null) {
      final lastDate = DateTime.parse(lastWorkoutDate);
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 1) {
        final currentStreak = prefs.getInt('workout_streak') ?? 0;
        await prefs.setInt('workout_streak', currentStreak + 1);
      } else if (daysDiff > 1) {
        await prefs.setInt('workout_streak', 1);
      }
    } else {
      await prefs.setInt('workout_streak', 1);
    }

    await prefs.setString('last_workout_date', today.toIso8601String());
  }

  String getRandomMotivation() {
    return _motivationalMessages[Random().nextInt(_motivationalMessages.length)];
  }
}
