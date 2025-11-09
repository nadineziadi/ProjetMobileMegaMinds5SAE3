// lib/pages/workout/workout_detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_model.dart';
import 'workout_form_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.workout.duration * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = widget.workout.duration * 60;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFFC7F000), size: 32),
            SizedBox(width: 12),
            Text(
              "Bravo !",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Vous avez terminé votre entraînement !",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFC7F000),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text(
              "Recommencer",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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

  IconData _getWorkoutIcon() {
    switch (widget.workout.type) {
      case 'Cardio':
        return Icons.directions_run_rounded;
      case 'Force':
        return Icons.fitness_center_rounded;
      case 'Étirement':
        return Icons.self_improvement_rounded;
      case 'Yoga':
        return Icons.spa_rounded;
      case 'HIIT':
        return Icons.local_fire_department_rounded;
      case 'CrossFit':
        return Icons.sports_gymnastics_rounded;
      case 'Natation':
        return Icons.pool_rounded;
      case 'Course':
        return Icons.directions_run_rounded;
      case 'Cyclisme':
        return Icons.directions_bike_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutColor = _getWorkoutColor();
    final progress = 1 - (_secondsRemaining / (widget.workout.duration * 60));

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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2124),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2124),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutFormScreen(
                                existingWorkout: widget.workout,
                              ),
                            ),
                          );
                          if (mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.edit_rounded, color: Color(0xFFC7F000)),
                      ),
                    ),
                  ],
                ),
              ),

              // Workout Icon & Title
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: workoutColor.withOpacity(0.2),
                          border: Border.all(
                            color: workoutColor.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _getWorkoutIcon(),
                          size: 80,
                          color: workoutColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.workout.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: workoutColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
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
                      const SizedBox(height: 32),

                      // Timer Display
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(workoutColor),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                _formatTime(_secondsRemaining),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -2,
                                ),
                              ),
                              Text(
                                _isRunning
                                    ? 'En cours...'
                                    : _isPaused
                                        ? 'En pause'
                                        : 'Prêt à commencer',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isRunning || _isPaused) ...[
                            _buildControlButton(
                              icon: Icons.refresh_rounded,
                              label: 'Reset',
                              color: Colors.grey,
                              onPressed: _resetTimer,
                            ),
                            const SizedBox(width: 16),
                          ],
                          _buildControlButton(
                            icon: _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            label: _isRunning
                                ? 'Pause'
                                : _isPaused
                                    ? 'Reprendre'
                                    : 'Démarrer',
                            color: workoutColor,
                            onPressed: _isRunning ? _pauseTimer : _startTimer,
                            isMain: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time_rounded,
                              label: 'Durée',
                              value: '${widget.workout.duration} min',
                              color: workoutColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Calories',
                              value: widget.workout.caloriesBurned != null
                                  ? '${widget.workout.caloriesBurned}'
                                  : '-',
                              color: workoutColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: DateFormat('dd MMMM yyyy', 'fr_FR')
                            .format(widget.workout.date),
                        color: workoutColor,
                      ),

                      if (widget.workout.notes != null &&
                          widget.workout.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2124),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.note_rounded,
                                    color: workoutColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Notes',
                                    style: TextStyle(
                                      color: workoutColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.workout.notes!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isMain = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isMain
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(
            horizontal: isMain ? 48 : 32,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMain ? 32 : 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isMain ? 20 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}