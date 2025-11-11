import '../models/user_progress.dart';
import '../models/program.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class AdaptationService {
  // Analyze workout logs and determine if adaptation is needed
  static AdaptationRecommendation analyzeProgress(
    List<WorkoutLog> recentLogs,
    Program program,
  ) {
    if (recentLogs.isEmpty) {
      return AdaptationRecommendation(
        shouldAdapt: false,
        type: AdaptationType.none,
        reason: '',
        suggestedChange: '',
      );
    }

    // Get last 5 workouts (excluding rest days)
    final workoutLogs = recentLogs
        .where((log) => log.completed && log.fatigueLevel != null)
        .take(5)
        .toList();

    if (workoutLogs.length < 3) {
      // Not enough data yet
      return AdaptationRecommendation(
        shouldAdapt: false,
        type: AdaptationType.none,
        reason: 'Not enough workout data yet',
        suggestedChange: '',
      );
    }

    // Calculate average fatigue
    double avgFatigue = workoutLogs
            .map((log) => log.fatigueLevel!)
            .reduce((a, b) => a + b) /
        workoutLogs.length;

    // Count skipped workouts in last 7 days
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final skippedCount = recentLogs
        .where((log) =>
            !log.completed && log.date.isAfter(lastWeek))
        .length;

    // Check for overtraining signs
    if (avgFatigue >= 4.0 || skippedCount >= 2) {
      return AdaptationRecommendation(
        shouldAdapt: true,
        type: AdaptationType.decrease,
        reason: _getDecreaseReason(avgFatigue, skippedCount),
        suggestedChange: 'Reduce workout intensity by 15%',
        intensityMultiplier: 0.85,
      );
    }

    // Check if workouts are too easy
    if (avgFatigue <= 2.0 && workoutLogs.length >= 5) {
      return AdaptationRecommendation(
        shouldAdapt: true,
        type: AdaptationType.increase,
        reason: 'Your workouts seem too easy! You\'re consistently reporting low fatigue levels.',
        suggestedChange: 'Increase workout intensity by 10%',
        intensityMultiplier: 1.10,
      );
    }

    // Everything is fine
    return AdaptationRecommendation(
      shouldAdapt: false,
      type: AdaptationType.none,
      reason: 'Your workout intensity looks perfect!',
      suggestedChange: '',
    );
  }

  static String _getDecreaseReason(double avgFatigue, int skippedCount) {
    if (avgFatigue >= 4.5) {
      return 'You\'ve been reporting very high fatigue levels (${avgFatigue.toStringAsFixed(1)}/5). Let\'s reduce intensity to prevent burnout.';
    } else if (skippedCount >= 3) {
      return 'You\'ve missed $skippedCount workouts this week. A lighter program might help you stay consistent.';
    } else {
      return 'Your fatigue levels (${avgFatigue.toStringAsFixed(1)}/5) and $skippedCount missed workouts suggest you need recovery time.';
    }
  }

  // Apply adaptation to program workouts
  static Program adaptProgram(
    Program program,
    double intensityMultiplier,
  ) {
    List<Workout> adaptedWorkouts = program.workouts.map((workout) {
      if (workout.isRestDay) return workout;

      // Adapt exercises
      List<Exercise> adaptedExercises = workout.exercises.map((exercise) {
        int newSets = (exercise.sets * intensityMultiplier).round();
        int newReps = (exercise.reps * intensityMultiplier).round();

        // Ensure minimum values
        newSets = newSets < 1 ? 1 : newSets;
        newReps = newReps < 1 ? 1 : newReps;

        return Exercise(
          id: exercise.id,
          name: exercise.name,
          description: exercise.description,
          sets: newSets,
          reps: newReps,
          equipment: exercise.equipment,
          difficulty: exercise.difficulty,
        );
      }).toList();

      // Adjust duration
      int newDuration = (workout.durationMinutes * intensityMultiplier).round();

      return Workout(
        id: workout.id,
        name: workout.name,
        description: workout.description,
        exercises: adaptedExercises,
        durationMinutes: newDuration,
        difficulty: workout.difficulty,
      );
    }).toList();

    return Program(
      id: program.id,
      name: program.name,
      description: program.description,
      goal: program.goal,
      durationWeeks: program.durationWeeks,
      workouts: adaptedWorkouts,
      difficulty: program.difficulty,
      equipment: program.equipment,
    );
  }
}

// Recommendation result
class AdaptationRecommendation {
  final bool shouldAdapt;
  final AdaptationType type;
  final String reason;
  final String suggestedChange;
  final double? intensityMultiplier;

  AdaptationRecommendation({
    required this.shouldAdapt,
    required this.type,
    required this.reason,
    required this.suggestedChange,
    this.intensityMultiplier,
  });
}

enum AdaptationType {
  none,
  increase,
  decrease,
}