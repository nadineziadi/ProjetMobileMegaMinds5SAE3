// lib/pages/workout/workout_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../models/workout_model.dart'; 
class WorkoutSummaryScreen extends StatefulWidget {
  final Workout workout;
  final int actualDuration; // in seconds
  final int caloriesBurned;

  const WorkoutSummaryScreen({
    super.key,
    required this.workout,
    required this.actualDuration,
    required this.caloriesBurned,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _statsController;
  int _totalWorkouts = 0;
  int _totalCalories = 0;
  int _workoutStreak = 0;
  String _motivationalMessage = '';
  List<String> _achievements = [];

  // Motivational messages in French
  final List<String> _motivationalMessages = [
    "Incroyable effort ! Vous progressez à chaque entraînement ! 💪",
    "La consistance est la clé du succès ! Continuez comme ça ! 🚀",
    "Votre détermination inspire ! Félicitations pour cet accomplissement ! 🌟",
    "Chaque répétition vous rapproche de vos objectifs ! Bravo ! 🏆",
    "Vous avez dominé cet entraînement ! Votre progression est remarquable ! ⚡",
    "Le succès se construit une séance à la fois ! Félicitations ! 🎯",
    "Votre discipline porte ses fruits ! Continuez sur cette lancée ! 💫",
    "Chaque goutte de sucre vous rend plus fort ! Excellent travail ! 🔥",
    "Vous êtes sur la voie du succès ! Félicitations pour cette séance ! ✨",
    "La persévérance est votre super-pouvoir ! Magnifique effort ! 🦸‍♂️"
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadStats();
    _saveWorkoutStats();
    
    // Set random motivational message
    _motivationalMessage = _motivationalMessages[Random().nextInt(_motivationalMessages.length)];
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _scaleController.forward();
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalWorkouts = prefs.getInt('total_workouts') ?? 0;
      _totalCalories = prefs.getInt('total_calories_burned') ?? 0;
      _workoutStreak = prefs.getInt('workout_streak') ?? 0;
    });

    _checkAchievements();
  }

  Future<void> _saveWorkoutStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update totals
    final totalWorkouts = (prefs.getInt('total_workouts') ?? 0) + 1;
    final totalCalories = (prefs.getInt('total_calories_burned') ?? 0) + widget.caloriesBurned;
    
    await prefs.setInt('total_workouts', totalWorkouts);
    await prefs.setInt('total_calories_burned', totalCalories);
    
    // Update streak (simplified version)
    final lastWorkoutDate = prefs.getString('last_workout_date');
    final today = DateTime.now().toString().split(' ')[0];
    
    if (lastWorkoutDate == today) {
      // Already worked out today, don't change streak
    } else if (lastWorkoutDate != null) {
      final lastDate = DateTime.parse(lastWorkoutDate);
      final todayDate = DateTime.now();
      final difference = todayDate.difference(lastDate).inDays;
      
      if (difference == 1) {
        // Consecutive day
        final currentStreak = prefs.getInt('workout_streak') ?? 0;
        await prefs.setInt('workout_streak', currentStreak + 1);
      } else if (difference > 1) {
        // Streak broken
        await prefs.setInt('workout_streak', 1);
      }
    } else {
      // First workout
      await prefs.setInt('workout_streak', 1);
    }
    
    await prefs.setString('last_workout_date', today);
    
    // Save this workout summary
    final summaryKey = 'workout_summary_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(summaryKey, '${widget.workout.name}|${widget.actualDuration}|${widget.caloriesBurned}');
    
    _loadStats();
  }

  void _checkAchievements() {
    final achievements = <String>[];
    
    if (_totalWorkouts == 1) {
      achievements.add('🎯 Premier entraînement complété !');
    } else if (_totalWorkouts == 10) {
      achievements.add('🏅 10 entraînements complétés !');
    } else if (_totalWorkouts == 50) {
      achievements.add('👑 50 entraînements - Vous êtes une légende !');
    }
    
    if (_workoutStreak >= 7) {
      achievements.add('🔥 Série de ${_workoutStreak} jours !');
    }
    
    if (_totalCalories >= 1000) {
      achievements.add('💪 Plus de 1000 calories brûlées !');
    }
    
    if (widget.actualDuration >= widget.workout.duration * 60) {
      achievements.add('⏱️ Objectif de temps atteint !');
    }

    setState(() {
      _achievements = achievements;
    });
  }

  void _shareResults() {
    final actualMinutes = (widget.actualDuration / 60).round();
    final shareText = 
        "💪 Je viens de terminer mon entraînement ${widget.workout.name} !\n"
        "⏱️ Durée : $actualMinutes minutes\n"
        "🔥 Calories brûlées : ${widget.caloriesBurned} kcal\n"
        "🎯 Type : ${widget.workout.type}\n"
        "📈 Progression totale : $_totalWorkouts séances complétées\n\n"
        "Avec GYMINI, chaque séance compte ! 💫";

    Share.share(shareText, subject: 'Mes résultats d\'entraînement GYMINI');
  }

  Color _getWorkoutColor() {
    switch (widget.workout.type) {
      case 'Cardio':
        return const Color(0xFFFF6B6B);
      case 'Force':
        return const Color(0xFFFF8E53);
      case 'Étirement':
        return const Color(0xFF4ECDC4);
      case 'Yoga':
        return const Color(0xFFB565D8);
      case 'HIIT':
        return const Color(0xFFF9CA24);
      case 'CrossFit':
        return const Color(0xFF6C5CE7);
      case 'Natation':
        return const Color(0xFF00B894);
      case 'Course':
        return const Color(0xFFE17055);
      case 'Cyclisme':
        return const Color(0xFF0984E3);
      default:
        return const Color(0xFFC7F000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutColor = _getWorkoutColor();
    final actualMinutes = (widget.actualDuration / 60).round();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              workoutColor.withOpacity(0.3),
              const Color(0xFF121416),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                colors: [
                  workoutColor,
                  const Color(0xFFC7F000),
                  Colors.white,
                  Colors.orange,
                ],
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Success Icon
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              workoutColor,
                              workoutColor.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: workoutColor.withOpacity(0.5),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Bravo !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        shadows: [
                          Shadow(
                            color: workoutColor.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.workout.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: workoutColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: workoutColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        widget.workout.type,
                        style: TextStyle(
                          color: workoutColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Stats Cards
                    FadeTransition(
                      opacity: _statsController,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.access_time_rounded,
                                  label: 'Durée',
                                  value: '$actualMinutes',
                                  unit: 'min',
                                  color: workoutColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.local_fire_department_rounded,
                                  label: 'Calories',
                                  value: '${widget.caloriesBurned}',
                                  unit: 'kcal',
                                  color: workoutColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.fitness_center_rounded,
                                  label: 'Total',
                                  value: '$_totalWorkouts',
                                  unit: 'séances',
                                  color: workoutColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.local_fire_department,
                                  label: 'Série',
                                  value: '$_workoutStreak',
                                  unit: 'jours',
                                  color: workoutColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Motivational Message
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            workoutColor.withOpacity(0.2),
                            workoutColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: workoutColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: workoutColor,
                            size: 32,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _motivationalMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Achievements
                    if (_achievements.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2124),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFC7F000).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  color: const Color(0xFFC7F000),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Succès débloqués',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._achievements.map((achievement) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: workoutColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.star,
                                          color: workoutColor,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          achievement,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate back to workout list screen
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: workoutColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list_alt_rounded, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Retour aux entraînements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _shareResults,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_rounded, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  'Partager mes résultats',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E2124),
            const Color(0xFF1E2124).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}