// lib/pages/workout/workout_detail_screen.dart
import 'dart:async';
import 'dart:math'; // Add this import for sin and pi
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/workout_model.dart';
import '../services/workout_database.dart';
import 'workout_form_screen.dart';
import 'workout_summary_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> with WidgetsBindingObserver {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _totalWorkouts = 0;
  int _completedWorkouts = 0;
  bool _showVideo = false; // Toggle between timer and video
  late YoutubePlayerController _youtubeController;

  // Workout video mapping - Add your own video IDs here
  final Map<String, String> _workoutVideos = {
    'Cardio': 'ml6cT4AZdqI', // Sample cardio workout
    'Force': 'IODxDxX7oi4', // Sample strength workout
    'Étirement': 'g_tea8ZNk5A', // Sample stretching
    'Yoga': 'v7AYKMP6rOE', // Sample yoga
    'HIIT': '1skBf0gYm-k', // Sample HIIT
    'CrossFit': 'R2az5AJpB3o', // Sample CrossFit
    'Natation': 'tKJFSZxwzGs', // Sample swimming tutorial
    'Course': 'brFHyOtTwH4', // Sample running technique
    'Cyclisme': 'CKZHg8JmZ-Q', // Sample cycling
  };

  int _estimateCalories(String type, int duration) {
    Map<String, int> calorieRates = {
      'Cardio': 10,
      'Force': 8,
      'Étirement': 4,
      'Yoga': 5,
      'HIIT': 12,
      'CrossFit': 15,
      'Natation': 10,
      'Course': 11,
      'Cyclisme': 9,
    };
    int rate = calorieRates[type] ?? 7;
    return rate * duration;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProgress();
    _loadStats();
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    final videoId = _workoutVideos[widget.workout.type] ?? 'dQw4w9WgXcQ';
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _youtubeController.dispose();
    _saveProgress();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveProgress();
      if (_showVideo) {
        _youtubeController.pause();
      }
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'workout_${widget.workout.id}_progress';
    final savedSeconds = prefs.getInt(key);
    
    setState(() {
      if (savedSeconds != null && savedSeconds > 0) {
        _secondsRemaining = savedSeconds;
        _isPaused = true;
      } else {
        _secondsRemaining = widget.workout.duration * 60;
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'workout_${widget.workout.id}_progress';
    
    if (_secondsRemaining > 0 && (_isRunning || _isPaused)) {
      await prefs.setInt(key, _secondsRemaining);
    } else if (_secondsRemaining == 0) {
      await prefs.remove(key);
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalWorkouts = prefs.getInt('total_workouts') ?? 0;
      _completedWorkouts = prefs.getInt('completed_workouts') ?? 0;
    });
  }

  Future<void> _incrementCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getInt('completed_workouts') ?? 0;
    await prefs.setInt('completed_workouts', completed + 1);
    
    final total = prefs.getInt('total_workouts') ?? 0;
    if (total == 0) {
      await prefs.setInt('total_workouts', 1);
    }
    
    _loadStats();
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
          if (_secondsRemaining % 10 == 0) {
            _saveProgress();
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          _incrementCompleted();
          _saveProgress();
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
    _saveProgress();
  }

  void _resetTimer() async {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = widget.workout.duration * 60;
      _isRunning = false;
      _isPaused = false;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workout_${widget.workout.id}_progress');
  }

  void _showCompletionDialog() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(
          workout: widget.workout,
          actualDuration: widget.workout.duration * 60,
          caloriesBurned: widget.workout.caloriesBurned ?? 
              _estimateCalories(widget.workout.type, widget.workout.duration),
        ),
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
    final workoutColor = _getWorkoutColor();
    final progress = 1 - (_secondsRemaining / (widget.workout.duration * 60));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              workoutColor.withOpacity(0.25),
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
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    // Toggle Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2124),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: workoutColor.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildToggleButton(
                            icon: Icons.timer_rounded,
                            isSelected: !_showVideo,
                            color: workoutColor,
                            onTap: () {
                              setState(() {
                                _showVideo = false;
                                _youtubeController.pause();
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildToggleButton(
                            icon: Icons.play_circle_outline_rounded,
                            isSelected: _showVideo,
                            color: workoutColor,
                            onTap: () {
                              setState(() {
                                _showVideo = true;
                                if (_isRunning) {
                                  _pauseTimer();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2124),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: workoutColor.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          _timer?.cancel();
                          _saveProgress();
                          
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
                        icon: Icon(Icons.edit_rounded, color: workoutColor),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Workout Icon & Title
                      Container(
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              workoutColor.withOpacity(0.3),
                              workoutColor.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: workoutColor.withOpacity(0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: workoutColor.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
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
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              workoutColor.withOpacity(0.3),
                              workoutColor.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: workoutColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          widget.workout.type,
                          style: TextStyle(
                            color: workoutColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Main Content Area (Timer or Video)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _showVideo
                            ? _buildVideoPlayer(workoutColor)
                            : _buildTimerView(workoutColor, progress),
                      ),
                      const SizedBox(height: 40),

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
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1E2124),
                                const Color(0xFF1E2124).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: workoutColor.withOpacity(0.2),
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
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Notes',
                                    style: TextStyle(
                                      color: workoutColor,
                                      fontSize: 16,
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
                                  height: 1.6,
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

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? color : Colors.white.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(Color workoutColor) {
    return Container(
      key: const ValueKey('video'),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: workoutColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: workoutColor.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: workoutColor,
                progressColors: ProgressBarColors(
                  playedColor: workoutColor,
                  handleColor: workoutColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: workoutColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: workoutColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: workoutColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Regardez la vidéo pour apprendre la technique',
                    style: TextStyle(
                      color: workoutColor.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTimerView(Color workoutColor, double progress) {
    return Container(
      key: const ValueKey('timer'),
      child: Column(
        children: [
          if (_isPaused && !_isRunning) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Progression sauvegardée',
                    style: TextStyle(
                      color: Colors.orange[200],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Timer Display with Animated Character
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow effect
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      workoutColor.withOpacity(_isRunning ? 0.3 : 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 300,
                height: 300,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(workoutColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Animated workout character
              _WorkoutAnimation(
                workoutType: widget.workout.type,
                color: workoutColor,
                isAnimating: _isRunning,
              ),
              // Timer text overlay
              Positioned(
                bottom: 40,
                child: Column(
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: workoutColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _isRunning
                            ? '🔥 En cours'
                            : _isPaused
                                ? '⏸️ En pause'
                                : '▶️ Prêt',
                        style: TextStyle(
                          color: workoutColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Control Buttons
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isSmallScreen = constraints.maxWidth < 400;
              
              if (isSmallScreen) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isRunning || _isPaused) ...[
                      SizedBox(
                        width: double.infinity,
                        child: _buildControlButton(
                          icon: Icons.refresh_rounded,
                          label: 'Reset',
                          color: Colors.grey[700]!,
                          onPressed: _resetTimer,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: _buildControlButton(
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
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRunning || _isPaused) ...[
                      _buildControlButton(
                        icon: Icons.refresh_rounded,
                        label: 'Reset',
                        color: Colors.grey[700]!,
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
                );
              }
            },
          ),
        ],
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
                  color: color.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          minimumSize: const Size(120, 60),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMain ? 28 : 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isMain ? 18 : 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
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
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E2124),
            const Color(0xFF1E2124).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
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

// Animated Workout Character Widget
class _WorkoutAnimation extends StatefulWidget {
  final String workoutType;
  final Color color;
  final bool isAnimating;

  const _WorkoutAnimation({
    required this.workoutType,
    required this.color,
    required this.isAnimating,
  });

  @override
  State<_WorkoutAnimation> createState() => _WorkoutAnimationState();
}

class _WorkoutAnimationState extends State<_WorkoutAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _getAnimationDuration(),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_WorkoutAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  Duration _getAnimationDuration() {
    switch (widget.workoutType) {
      case 'Cardio':
      case 'HIIT':
      case 'Course':
        return const Duration(milliseconds: 600); // Fast movements
      case 'Force':
      case 'CrossFit':
        return const Duration(milliseconds: 900); // Medium pace
      case 'Yoga':
      case 'Étirement':
        return const Duration(milliseconds: 1500); // Slow, flowing
      default:
        return const Duration(milliseconds: 800);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _WorkoutPainter(
            workoutType: widget.workoutType,
            color: widget.color,
            animationValue: _animation.value,
            isAnimating: widget.isAnimating,
          ),
        );
      },
    );
  }
}

class _WorkoutPainter extends CustomPainter {
  final String workoutType;
  final Color color;
  final double animationValue;
  final bool isAnimating;

  _WorkoutPainter({
    required this.workoutType,
    required this.color,
    required this.animationValue,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);

    switch (workoutType) {
      case 'Cardio':
      case 'Course':
        _drawRunningPerson(canvas, size, paint, center);
        break;
      case 'Force':
        _drawWeightlifter(canvas, size, paint, center);
        break;
      case 'Yoga':
      case 'Étirement':
        _drawYogaPose(canvas, size, paint, center);
        break;
      case 'HIIT':
        _drawJumpingPerson(canvas, size, paint, center);
        break;
      case 'CrossFit':
        _drawBurpee(canvas, size, paint, center);
        break;
      case 'Natation':
        _drawSwimmer(canvas, size, paint, center);
        break;
      case 'Cyclisme':
        _drawCyclist(canvas, size, paint, center);
        break;
      default:
        _drawGenericExercise(canvas, size, paint, center);
    }
  }

  void _drawRunningPerson(Canvas canvas, Size size, Paint paint, Offset center) {
    final headY = center.dy - 40 + (sin(animationValue * pi * 2) * 3);
    final bodyY = center.dy - 10;
    final legOffset = sin(animationValue * pi * 2) * 20;
    final armOffset = sin(animationValue * pi * 2) * 15;

    // Head
    canvas.drawCircle(Offset(center.dx, headY), 12, paint);

    // Body (leaning forward)
    canvas.drawLine(
      Offset(center.dx, headY + 12),
      Offset(center.dx + 5, bodyY + 20),
      paint..strokeWidth = 4,
    );

    // Arms (pumping motion)
    canvas.drawLine(
      Offset(center.dx + 5, bodyY),
      Offset(center.dx - 10 + armOffset, bodyY + 25),
      paint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(center.dx + 5, bodyY),
      Offset(center.dx + 20 - armOffset, bodyY + 20),
      paint..strokeWidth = 3,
    );

    // Legs (running motion)
    canvas.drawLine(
      Offset(center.dx + 5, bodyY + 20),
      Offset(center.dx - 5 + legOffset, bodyY + 50),
      paint..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(center.dx + 5, bodyY + 20),
      Offset(center.dx + 15 - legOffset, bodyY + 45),
      paint..strokeWidth = 4,
    );
  }

  void _drawWeightlifter(Canvas canvas, Size size, Paint paint, Offset center) {
    final liftHeight = isAnimating ? sin(animationValue * pi * 2) * 20 : 0;
    final armY = center.dy - 20 - liftHeight;

    // Head
    canvas.drawCircle(Offset(center.dx, center.dy - 40), 12, paint);

    // Body
    canvas.drawLine(
      Offset(center.dx, center.dy - 28),
      Offset(center.dx, center.dy + 10),
      paint..strokeWidth = 5,
    );

    // Barbell
    paint.strokeWidth = 6;
    canvas.drawLine(
      Offset(center.dx - 35, armY),
      Offset(center.dx + 35, armY),
      paint,
    );

    // Weights
    canvas.drawCircle(Offset(center.dx - 35, armY), 8, paint);
    canvas.drawCircle(Offset(center.dx + 35, armY), 8, paint);

    // Arms holding barbell
    paint.strokeWidth = 4;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy - 20),
      Offset(center.dx - 30, armY),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + 10, center.dy - 20),
      Offset(center.dx + 30, armY),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(center.dx, center.dy + 10),
      Offset(center.dx - 10, center.dy + 40),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 10),
      Offset(center.dx + 10, center.dy + 40),
      paint,
    );
  }

  void _drawYogaPose(Canvas canvas, Size size, Paint paint, Offset center) {
    final breathe = sin(animationValue * pi * 2) * 3;

    // Head
    canvas.drawCircle(Offset(center.dx, center.dy - 40 + breathe), 12, paint);

    // Body (straight)
    canvas.drawLine(
      Offset(center.dx, center.dy - 28 + breathe),
      Offset(center.dx, center.dy + 15 + breathe),
      paint..strokeWidth = 4,
    );

    // Arms extended (tree pose variation)
    final armSpread = 35 + breathe;
    canvas.drawLine(
      Offset(center.dx, center.dy - 15 + breathe),
      Offset(center.dx - armSpread, center.dy - 20 + breathe),
      paint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 15 + breathe),
      Offset(center.dx + armSpread, center.dy - 20 + breathe),
      paint..strokeWidth = 3,
    );

    // Hands
    canvas.drawCircle(Offset(center.dx - armSpread, center.dy - 20 + breathe), 4, paint);
    canvas.drawCircle(Offset(center.dx + armSpread, center.dy - 20 + breathe), 4, paint);

    // Legs (one leg standing, one bent)
    canvas.drawLine(
      Offset(center.dx, center.dy + 15 + breathe),
      Offset(center.dx, center.dy + 45),
      paint..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 15 + breathe),
      Offset(center.dx + 15, center.dy + 25 + breathe),
      paint..strokeWidth = 3,
    );
  }

  void _drawJumpingPerson(Canvas canvas, Size size, Paint paint, Offset center) {
    final jumpHeight = sin(animationValue * pi * 2) * 30;
    final baseY = center.dy - jumpHeight;

    // Head
    canvas.drawCircle(Offset(center.dx, baseY - 40), 12, paint);

    // Body
    canvas.drawLine(
      Offset(center.dx, baseY - 28),
      Offset(center.dx, baseY + 10),
      paint..strokeWidth = 4,
    );

    // Arms up (jumping jack style)
    final armAngle = jumpHeight / 30;
    canvas.drawLine(
      Offset(center.dx, baseY - 20),
      Offset(center.dx - 25 * armAngle, baseY - 35),
      paint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(center.dx, baseY - 20),
      Offset(center.dx + 25 * armAngle, baseY - 35),
      paint..strokeWidth = 3,
    );

    // Legs spread
    canvas.drawLine(
      Offset(center.dx, baseY + 10),
      Offset(center.dx - 20 * armAngle, baseY + 40),
      paint..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(center.dx, baseY + 10),
      Offset(center.dx + 20 * armAngle, baseY + 40),
      paint..strokeWidth = 4,
    );
  }

  void _drawBurpee(Canvas canvas, Size size, Paint paint, Offset center) {
    // Cycles through burpee positions
    final phase = (animationValue * 4) % 4;
    
    if (phase < 1) {
      // Standing
      _drawRunningPerson(canvas, size, paint, center);
    } else if (phase < 2) {
      // Squat down
      final squat = (phase - 1) * 20;
      canvas.drawCircle(Offset(center.dx, center.dy - 20 + squat), 12, paint);
      canvas.drawLine(
        Offset(center.dx, center.dy - 8 + squat),
        Offset(center.dx, center.dy + 20),
        paint..strokeWidth = 4,
      );
    } else if (phase < 3) {
      // Plank position
      canvas.drawCircle(Offset(center.dx - 20, center.dy), 10, paint);
      canvas.drawLine(
        Offset(center.dx - 20, center.dy + 10),
        Offset(center.dx + 20, center.dy + 10),
        paint..strokeWidth = 4,
      );
    } else {
      // Jump up
      _drawJumpingPerson(canvas, size, paint, center);
    }
  }

  void _drawSwimmer(Canvas canvas, Size size, Paint paint, Offset center) {
    final stroke = sin(animationValue * pi * 2);

    // Head
    canvas.drawCircle(Offset(center.dx - 15, center.dy - 10), 12, paint);

    // Body (horizontal)
    canvas.drawLine(
      Offset(center.dx - 15, center.dy),
      Offset(center.dx + 25, center.dy),
      paint..strokeWidth = 4,
    );

    // Arms (swimming motion)
    canvas.drawLine(
      Offset(center.dx - 5, center.dy),
      Offset(center.dx - 20 + stroke * 15, center.dy - 20 + stroke.abs() * 10),
      paint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(center.dx + 5, center.dy),
      Offset(center.dx + 20 - stroke * 15, center.dy - 20 + stroke.abs() * 10),
      paint..strokeWidth = 3,
    );

    // Legs (kicking)
    canvas.drawLine(
      Offset(center.dx + 20, center.dy),
      Offset(center.dx + 35, center.dy + stroke * 15),
      paint..strokeWidth = 3,
    );

    // Water ripples
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 30),
          width: 60 + i * 20,
          height: 20 + i * 5,
        ),
        0,
        pi,
        false,
        paint..color = color.withOpacity(0.3 - i * 0.1),
      );
    }
    paint.style = PaintingStyle.fill;
  }

  void _drawCyclist(Canvas canvas, Size size, Paint paint, Offset center) {
    final pedal = sin(animationValue * pi * 2);

    // Head
    canvas.drawCircle(Offset(center.dx - 10, center.dy - 35), 10, paint);

    // Body (leaning forward)
    canvas.drawLine(
      Offset(center.dx - 10, center.dy - 25),
      Offset(center.dx, center.dy),
      paint..strokeWidth = 4,
    );

    // Arms to handlebars
    canvas.drawLine(
      Offset(center.dx - 5, center.dy - 15),
      Offset(center.dx - 25, center.dy - 5),
      paint..strokeWidth = 3,
    );

    // Bike frame (simplified)
    paint.strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx - 25, center.dy - 5),
      Offset(center.dx, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + 20, center.dy),
      paint,
    );

    // Wheels
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(center.dx - 25, center.dy + 15), 15, paint);
    canvas.drawCircle(Offset(center.dx + 20, center.dy + 15), 15, paint);
    paint.style = PaintingStyle.fill;

    // Legs (pedaling motion)
    paint.strokeWidth = 3;
    final legAngle = pedal * 20;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + legAngle, center.dy + 20),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx - legAngle, center.dy + 20),
      paint,
    );
  }

  void _drawGenericExercise(Canvas canvas, Size size, Paint paint, Offset center) {
    final bounce = sin(animationValue * pi * 2) * 5;

    // Head
    canvas.drawCircle(Offset(center.dx, center.dy - 40 + bounce), 12, paint);

    // Body
    canvas.drawLine(
      Offset(center.dx, center.dy - 28 + bounce),
      Offset(center.dx, center.dy + 10 + bounce),
      paint..strokeWidth = 4,
    );

    // Arms
    canvas.drawLine(
      Offset(center.dx, center.dy - 15 + bounce),
      Offset(center.dx - 25, center.dy + bounce),
      paint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 15 + bounce),
      Offset(center.dx + 25, center.dy + bounce),
      paint..strokeWidth = 3,
    );

    // Legs
    canvas.drawLine(
      Offset(center.dx, center.dy + 10 + bounce),
      Offset(center.dx - 10, center.dy + 40),
      paint..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 10 + bounce),
      Offset(center.dx + 10, center.dy + 40),
      paint..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_WorkoutPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isAnimating != isAnimating;
  }
}