import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/workout.dart';
import '../models/user_progress.dart';
import '../services/database_helper.dart';
import '../services/adaptation_service.dart';

class ProgramProvider extends ChangeNotifier {
  List<Program> _programs = [];
  Program? _selectedProgram;
  List<WorkoutLog> _workoutLogs = [];

  AdaptationRecommendation? _lastRecommendation;

  // Getters
  List<Program> get programs => _programs;
  Program? get selectedProgram => _selectedProgram;
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  AdaptationRecommendation? get lastRecommendation => _lastRecommendation;

  // Load all programs
  Future<void> loadPrograms() async {
    _programs = await DatabaseHelper.instance.getAllPrograms();
    notifyListeners();
  }

  // Select program
  Future<void> selectProgram(int programId) async {
    _selectedProgram = await DatabaseHelper.instance.getProgramById(programId);
    await loadWorkoutLogs();
    notifyListeners();
  }

  // Load workout logs
  Future<void> loadWorkoutLogs() async {
    _workoutLogs = await DatabaseHelper.instance.getWorkoutLogs();
    notifyListeners();
  }

  // Delete program
  Future<void> deleteProgram(int programId) async {
    await DatabaseHelper.instance.deleteProgram(programId);
    await loadPrograms();
    notifyListeners();
  }

  // Update program
  Future<void> updateProgram(Program program) async {
    await DatabaseHelper.instance.updateProgram(program);
    await loadPrograms();
    notifyListeners();
  }

  // Log workout
  Future<void> logWorkout(
    int workoutId,
    bool completed, {
    String? notes,
    int? fatigueLevel,
  }) async {
    final log = WorkoutLog(
      workoutId: workoutId,
      date: DateTime.now(),
      completed: completed,
      notes: notes,
      fatigueLevel: fatigueLevel,
    );

    await DatabaseHelper.instance.insertWorkoutLog(log);
    await loadWorkoutLogs();
    notifyListeners();
  }

  // Count completed workouts
  int getCompletedWorkoutsCount() {
    return _workoutLogs.where((log) => log.completed).length;
  }

  // Check if workout done today
  bool isWorkoutCompletedToday(int workoutId) {
    final today = DateTime.now();
    return _workoutLogs.any((log) =>
        log.workoutId == workoutId &&
        log.completed &&
        log.date.year == today.year &&
        log.date.month == today.month &&
        log.date.day == today.day);
  }

  // -----------------------------
  // ✅ ADAPTATION LOGIC
  // -----------------------------

  // Check if we need to adapt program
  Future<AdaptationRecommendation> checkAdaptation() async {
    if (_selectedProgram == null) {
      return AdaptationRecommendation(
        shouldAdapt: false,
        type: AdaptationType.none,
        reason: '',
        suggestedChange: '',
      );
    }

    _lastRecommendation = AdaptationService.analyzeProgress(
      _workoutLogs,
      _selectedProgram!,
    );

    notifyListeners();
    return _lastRecommendation!;
  }

  // Apply adaptation to program
Future<void> applyAdaptation(double intensityMultiplier) async {
  print('🔄 START applyAdaptation');
  print('Selected program: ${_selectedProgram?.name}');
  print('Selected program ID: ${_selectedProgram?.id}');
  
  if (_selectedProgram == null) {
    print('❌ No selected program');
    return;
  }

  try {
    print('🔄 Step 1: Adapting program in memory...');
    final adaptedProgram = AdaptationService.adaptProgram(
      _selectedProgram!,
      intensityMultiplier,
    );
    print('✅ Program adapted');
    print('   - Program ID: ${adaptedProgram.id}');
    print('   - Workouts count: ${adaptedProgram.workouts.length}');
    
    // Check workout IDs
    for (var workout in adaptedProgram.workouts) {
      print('   - Workout: ${workout.name}, ID: ${workout.id}, Exercises: ${workout.exercises.length}');
    }

    print('🔄 Step 2: Updating database...');
    await DatabaseHelper.instance.updateProgramWithWorkouts(adaptedProgram);
    print('✅ Database updated');

    print('🔄 Step 3: Reloading programs...');
    await loadPrograms();
    print('✅ Programs reloaded');

    print('🔄 Step 4: Selecting program again...');
    await selectProgram(_selectedProgram!.id!);
    print('✅ Program selected');

    _lastRecommendation = null;
    notifyListeners();
    
    print('✅ COMPLETE applyAdaptation');
  } catch (e, stackTrace) {
    print('❌ ERROR in applyAdaptation: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

  // Dismiss adaptation suggestion
  void dismissAdaptation() {
    _lastRecommendation = null;
    notifyListeners();
  }
}
