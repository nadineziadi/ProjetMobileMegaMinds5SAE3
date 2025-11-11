// lib/widgets/workout_recommendation_card.dart
import 'package:flutter/material.dart';
import '../services/workout_recommender.dart';
import '../models/workout_model.dart';
import '../services/workout_database.dart';

class WorkoutRecommendationCard extends StatefulWidget {
  final VoidCallback? onWorkoutCreated;

  const WorkoutRecommendationCard({
    super.key,
    this.onWorkoutCreated,
  });

  @override
  State<WorkoutRecommendationCard> createState() => _WorkoutRecommendationCardState();
}

class _WorkoutRecommendationCardState extends State<WorkoutRecommendationCard> {
  WorkoutRecommendation? _recommendation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

Future<void> _loadRecommendation() async {
  if (!mounted) return; // <-- just in case
  setState(() => _isLoading = true);

  final recommendation = await WorkoutRecommender.instance.getRecommendation();

  if (!mounted) return; // <-- check before updating state
  setState(() {
    _recommendation = recommendation;
    _isLoading = false;
  });
}

  // --- NEW: Save workout to database ---
  Future<void> _saveRecommendation(Workout workout) async {
    await WorkoutDatabase.instance.create(workout);
    if (mounted) {
      widget.onWorkoutCreated?.call(); // refresh the parent list
    }
  }

  Color _getWorkoutColor(String type) {
    switch (type) {
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

  IconData _getWorkoutIcon(String type) {
    switch (type) {
      case 'Cardio':
        return Icons.favorite;
      case 'Force':
        return Icons.fitness_center;
      case 'Étirement':
        return Icons.self_improvement;
      case 'Yoga':
        return Icons.spa;
      case 'HIIT':
        return Icons.local_fire_department;
      case 'CrossFit':
        return Icons.sports_gymnastics;
      case 'Natation':
        return Icons.pool;
      case 'Course':
        return Icons.directions_run;
      case 'Cyclisme':
        return Icons.directions_bike;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E2124),
              const Color(0xFF1E2124).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC7F000),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_recommendation == null) return const SizedBox.shrink();

    final workoutColor = _getWorkoutColor(_recommendation!.type);
    final workoutIcon = _getWorkoutIcon(_recommendation!.type);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            workoutColor.withOpacity(0.15),
            const Color(0xFF1E2124),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: workoutColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: workoutColor.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -30,
            top: -30,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                workoutIcon,
                size: 180,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            workoutColor,
                            workoutColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: workoutColor.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommandation',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Smart AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: workoutColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: workoutColor.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: workoutColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(_recommendation!.confidenceScore * 100).round()}%',
                            style: TextStyle(
                              color: workoutColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  _recommendation!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  _recommendation!.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Motivational Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: workoutColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: workoutColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: workoutColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _recommendation!.motivationalMessage,
                          style: TextStyle(
                            color: workoutColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        icon: Icons.access_time_rounded,
                        label: '${_recommendation!.suggestedDuration} min',
                        color: workoutColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip(
                        icon: Icons.local_fire_department_rounded,
                        label: '~${_recommendation!.estimatedCalories} cal',
                        color: workoutColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loadRecommendation,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Autre',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_recommendation == null) return;

                          final workout = Workout(
                            name: _recommendation!.title,
                            type: _recommendation!.type,
                            duration: _recommendation!.suggestedDuration,
                            date: DateTime.now(),
                            caloriesBurned: _recommendation!.estimatedCalories,
                          );

                          // Save directly to database
                          await _saveRecommendation(workout);

                          // Reload recommendation
                          _loadRecommendation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: workoutColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_rounded, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Créer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Reason
                Center(
                  child: Text(
                    '💡 ${_recommendation!.reason}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
