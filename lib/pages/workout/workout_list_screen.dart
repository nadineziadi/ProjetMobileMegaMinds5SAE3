// lib/pages/workout/workout_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../services/workout_database.dart';
import 'workout_form_screen.dart';
import 'package:intl/intl.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  late Future<List<Workout>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _refreshWorkouts();
  }

  void _refreshWorkouts() {
    setState(() {
      _workoutsFuture = WorkoutDatabase.instance.readAll();
    });
  }

  void _deleteWorkout(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(),
    );

    if (confirm == true) {
      await WorkoutDatabase.instance.delete(id);
      _refreshWorkouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar('Entraînement supprimé', Icons.check_circle),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Workout>>(
              future: _workoutsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final workouts = snapshot.data ?? [];

                if (workouts.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildWorkoutList(workouts);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF353A40).withOpacity(0.5),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7F000).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFC7F000).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFFC7F000),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Entraînements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Suivez votre progression',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatsButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2D31),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: _showStatistics,
        icon: const Icon(Icons.analytics_rounded, color: Color(0xFFC7F000)),
        tooltip: 'Statistiques',
      ),
    );
  }

  Widget _buildWorkoutList(List<Workout> workouts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return _WorkoutCard(
          workout: workout,
          onTap: () => _editWorkout(workout),
          onDelete: () => _deleteWorkout(workout.id!),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2124),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC7F000).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFFC7F000),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chargement...',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2124),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC7F000).withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 80,
              color: const Color(0xFFC7F000).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Aucun entraînement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Commencez votre parcours fitness\nen ajoutant votre premier workout !',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFC7F000).withOpacity(0.15),
                  const Color(0xFFC7F000).withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2124),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: const Color(0xFFC7F000),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Appuyez sur le bouton +',
                    style: TextStyle(
                      color: Color(0xFFC7F000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Erreur: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC7F000).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutFormScreen()),
          );
          _refreshWorkouts();
        },
        backgroundColor: const Color(0xFFC7F000),
        icon: const Icon(Icons.add_rounded, color: Color(0xFF121416), size: 28),
        label: const Text(
          'Ajouter',
          style: TextStyle(
            color: Color(0xFF121416),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _editWorkout(Workout workout) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutFormScreen(existingWorkout: workout),
      ),
    );
    _refreshWorkouts();
  }

  void _showStatistics() async {
    final workouts = await _workoutsFuture;
    if (!mounted) return;

    final stats = _calculateStats(workouts);

    showDialog(
      context: context,
      builder: (context) => _buildStatsDialog(stats),
    );
  }

  Map<String, dynamic> _calculateStats(List<Workout> workouts) {
    int totalWorkouts = workouts.length;
    int totalDuration = workouts.fold(0, (sum, w) => sum + w.duration);
    int totalCalories = workouts.fold(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklyWorkouts = workouts.where((w) => w.date.isAfter(startOfWeek)).toList();
    
    int weeklyDuration = weeklyWorkouts.fold(0, (sum, w) => sum + w.duration);
    int weeklyCalories = weeklyWorkouts.fold(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

    return {
      'totalWorkouts': totalWorkouts,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'weeklyDuration': weeklyDuration,
      'weeklyCalories': weeklyCalories,
    };
  }

  Widget _buildStatsDialog(Map<String, dynamic> stats) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFC7F000).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7F000).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Color(0xFFC7F000),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _StatRow(
              icon: Icons.fitness_center_rounded,
              label: 'Total d\'entraînements',
              value: '${stats['totalWorkouts']}',
            ),
            _StatRow(
              icon: Icons.access_time_rounded,
              label: 'Durée totale',
              value: '${stats['totalDuration']} min',
            ),
            _StatRow(
              icon: Icons.local_fire_department_rounded,
              label: 'Calories brûlées',
              value: '${stats['totalCalories']} kcal',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFF2A2D31)),
            ),
            _StatRow(
              icon: Icons.calendar_today_rounded,
              label: 'Cette semaine (durée)',
              value: '${stats['weeklyDuration']} min',
              highlight: true,
            ),
            _StatRow(
              icon: Icons.whatshot_rounded,
              label: 'Cette semaine (calories)',
              value: '${stats['weeklyCalories']} kcal',
              highlight: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7F000),
                  foregroundColor: const Color(0xFF121416),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Supprimer l\'entraînement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Cette action est irréversible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A2D31)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(String message, IconData icon) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: const Color(0xFFC7F000)),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
      backgroundColor: const Color(0xFF1E2124),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// Workout Card Widget
class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WorkoutCard({
    required this.workout,
    required this.onTap,
    required this.onDelete,
  });

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return const Color(0xFFFF6B6B);
      case 'force':
        return const Color(0xFFFF8E53);
      case 'étirement':
        return const Color(0xFF4ECDC4);
      case 'yoga':
        return const Color(0xFFB565D8);
      case 'hiit':
        return const Color(0xFFF9CA24);
      default:
        return const Color(0xFFC7F000);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run_rounded;
      case 'force':
        return Icons.fitness_center_rounded;
      case 'étirement':
        return Icons.self_improvement_rounded;
      case 'yoga':
        return Icons.spa_rounded;
      case 'hiit':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(workout.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2D31),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: typeColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getTypeIcon(workout.type),
                        color: typeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workout.type,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: Colors.redAccent,
                      iconSize: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: '${workout.duration} min',
                      color: const Color(0xFFC7F000),
                    ),
                    const SizedBox(width: 8),
                    if (workout.caloriesBurned != null)
                      _InfoChip(
                        icon: Icons.local_fire_department_rounded,
                        label: '${workout.caloriesBurned} kcal',
                        color: const Color(0xFFFF6B6B),
                      ),
                    const Spacer(),
                    Text(
                      DateFormat('dd/MM/yy').format(workout.date),
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121416),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2A2D31),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      workout.notes!,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Row Widget
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: highlight ? const Color(0xFFC7F000) : const Color(0xFF9E9E9E),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? const Color(0xFFC7F000) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}