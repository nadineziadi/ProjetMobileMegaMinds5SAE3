import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/program.dart';
import '../models/user_progress.dart';
import '../models/exercise_library.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // ⚠️ CHANGED: Increment version to 2
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Add upgrade handler
    );
  }

  Future _createDB(Database db, int version) async {
    // Original tables
    await db.execute('''
      CREATE TABLE programs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        goal TEXT NOT NULL,
        duration_weeks INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        equipment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        program_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        is_rest_day INTEGER NOT NULL,
        day_order INTEGER NOT NULL,
        FOREIGN KEY (program_id) REFERENCES programs (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        equipment TEXT,
        difficulty TEXT NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL,
        notes TEXT,
        fatigue_level INTEGER,
        FOREIGN KEY (workout_id) REFERENCES workouts (id)
      )
    ''');
    
    // ✅ NEW: Create exercise library table
    await db.execute('''
      CREATE TABLE exercise_library(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        muscleGroups TEXT NOT NULL,
        equipment TEXT NOT NULL,
        videoUrl TEXT,
        thumbnailUrl TEXT,
        instructions TEXT NOT NULL,
        tips TEXT,
        commonMistakes TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    
    await _insertSampleData(db);
  }

  // ✅ NEW: Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add exercise_library table for existing users
      await db.execute('''
        CREATE TABLE exercise_library(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          difficulty TEXT NOT NULL,
          muscleGroups TEXT NOT NULL,
          equipment TEXT NOT NULL,
          videoUrl TEXT,
          thumbnailUrl TEXT,
          instructions TEXT NOT NULL,
          tips TEXT,
          commonMistakes TEXT,
          isFavorite INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _insertSampleData(Database db) async {
    int programId = await db.insert('programs', {
      'name': '4-Week Fat Loss Challenge',
      'description': 'A comprehensive fat loss program',
      'goal': 'fat_loss',
      'duration_weeks': 4,
      'difficulty': 'medium',
      'equipment': 'none',
    });
    List<Map<String, dynamic>> workouts = [
      {
        'program_id': programId,
        'name': 'Upper Body Strength',
        'description': 'Push-ups and upper body exercises',
        'duration_minutes': 30,
        'difficulty': 'medium',
        'is_rest_day': 0,
        'day_order': 1,
      },
      {
        'program_id': programId,
        'name': 'Lower Body Power',
        'description': 'Squats and leg exercises',
        'duration_minutes': 35,
        'difficulty': 'medium',
        'is_rest_day': 0,
        'day_order': 2,
      },
      {
        'program_id': programId,
        'name': 'Cardio Blast',
        'description': 'High-intensity cardio',
        'duration_minutes': 40,
        'difficulty': 'hard',
        'is_rest_day': 0,
        'day_order': 3,
      },
      {
        'program_id': programId,
        'name': 'Active Recovery',
        'description': 'Light stretching and mobility',
        'duration_minutes': 20,
        'difficulty': 'easy',
        'is_rest_day': 0,
        'day_order': 4,
      },
      {
        'program_id': programId,
        'name': 'Full Body',
        'description': 'Complete body workout',
        'duration_minutes': 45,
        'difficulty': 'medium',
        'is_rest_day': 0,
        'day_order': 5,
      },
      {
        'program_id': programId,
        'name': 'HIIT Session',
        'description': 'High intensity interval training',
        'duration_minutes': 30,
        'difficulty': 'hard',
        'is_rest_day': 0,
        'day_order': 6,
      },
      {
        'program_id': programId,
        'name': 'Rest Day',
        'description': 'Complete rest and recovery',
        'duration_minutes': 0,
        'difficulty': 'easy',
        'is_rest_day': 1,
        'day_order': 7,
      },
    ];
    for (var workout in workouts) {
      int workoutId = await db.insert('workouts', workout);
      if (workout['is_rest_day'] == 0) {
        await db.insert('exercises', {
          'workout_id': workoutId,
          'name': 'Push-ups',
          'description': 'Standard push-ups',
          'sets': 3,
          'reps': 10,
          'equipment': 'none',
          'difficulty': 'medium',
        });
        await db.insert('exercises', {
          'workout_id': workoutId,
          'name': 'Squats',
          'description': 'Bodyweight squats',
          'sets': 3,
          'reps': 15,
          'equipment': 'none',
          'difficulty': 'medium',
        });
      }
    }
  }

  // ============================================
  // PROGRAM METHODS (existing - no changes)
  // ============================================
  
  Future<List<Program>> getAllPrograms() async {
    final db = await database;
    final programMaps = await db.query('programs');
    List<Program> programs = [];
    for (var programMap in programMaps) {
      final workouts = await getWorkoutsByProgramId(programMap['id'] as int);
      programs.add(Program.fromMap(programMap, workouts));
    }
    return programs;
  }

  Future<Program?> getProgramById(int id) async {
    final db = await database;
    final maps = await db.query(
      'programs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final workouts = await getWorkoutsByProgramId(id);
      return Program.fromMap(maps.first, workouts);
    }
    return null;
  }

  Future<int> insertProgram(Program program) async {
    final db = await database;
    int programId = await db.insert('programs', program.toMap());
    for (int i = 0; i < program.workouts.length; i++) {
      final workout = program.workouts[i];
      int workoutId = await db.insert('workouts', {
        'program_id': programId,
        'name': workout.name,
        'description': workout.description,
        'duration_minutes': workout.durationMinutes,
        'difficulty': workout.difficulty,
        'is_rest_day': workout.isRestDay ? 1 : 0,
        'day_order': i + 1,
      });
      for (var exercise in workout.exercises) {
        await db.insert('exercises', {
          'workout_id': workoutId,
          'name': exercise.name,
          'description': exercise.description,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'equipment': exercise.equipment,
          'difficulty': exercise.difficulty,
        });
      }
    }
    return programId;
  }

  Future<void> updateProgram(Program program) async {
    final db = await database;
    await db.update(
      'programs',
      program.toMap(),
      where: 'id = ?',
      whereArgs: [program.id],
    );
  }

  Future<void> updateProgramWithWorkouts(Program program) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'programs',
        program.toMap(),
        where: 'id = ?',
        whereArgs: [program.id],
      );
      for (int i = 0; i < program.workouts.length; i++) {
        final workout = program.workouts[i];
        if (workout.id != null) {
          await txn.update(
            'workouts',
            {
              'name': workout.name,
              'description': workout.description,
              'duration_minutes': workout.durationMinutes,
              'difficulty': workout.difficulty,
              'is_rest_day': workout.isRestDay ? 1 : 0,
            },
            where: 'id = ?',
            whereArgs: [workout.id],
          );
          await txn.delete(
            'exercises',
            where: 'workout_id = ?',
            whereArgs: [workout.id],
          );
          for (var exercise in workout.exercises) {
            await txn.insert('exercises', {
              'workout_id': workout.id,
              'name': exercise.name,
              'description': exercise.description,
              'sets': exercise.sets,
              'reps': exercise.reps,
              'equipment': exercise.equipment,
              'difficulty': exercise.difficulty,
            });
          }
        }
      }
    });
  }

  Future<void> deleteProgram(int programId) async {
    final db = await database;
    final workouts = await db.query(
      'workouts',
      where: 'program_id = ?',
      whereArgs: [programId],
    );
    for (var workout in workouts) {
      await db.delete(
        'workout_logs',
        where: 'workout_id = ?',
        whereArgs: [workout['id']],
      );
      await db.delete(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [workout['id']],
      );
    }
    await db.delete(
      'workouts',
      where: 'program_id = ?',
      whereArgs: [programId],
    );
    await db.delete(
      'programs',
      where: 'id = ?',
      whereArgs: [programId],
    );
    await deleteOrphanWorkoutLogs();
  }

  Future<void> deleteOrphanWorkoutLogs() async {
    final db = await database;
    await db.delete(
      'workout_logs',
      where: 'workout_id NOT IN (SELECT id FROM workouts)'
    );
  }

  Future<List<Workout>> getWorkoutsByProgramId(int programId) async {
    final db = await database;
    final workoutMaps = await db.query(
      'workouts',
      where: 'program_id = ?',
      whereArgs: [programId],
      orderBy: 'day_order',
    );
    List<Workout> workouts = [];
    for (var workoutMap in workoutMaps) {
      final exercises = await getExercisesByWorkoutId(workoutMap['id'] as int);
      workouts.add(Workout.fromMap(workoutMap, exercises));
    }
    return workouts;
  }

  Future<void> updateWorkout(int workoutId, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'workouts',
      updates,
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<List<Exercise>> getExercisesByWorkoutId(int workoutId) async {
    final db = await database;
    final exerciseMaps = await db.query(
      'exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
    return exerciseMaps.map((map) => Exercise.fromMap(map)).toList();
  }

  // ============================================
  // WORKOUT LOG METHODS (existing - no changes)
  // ============================================

  Future<int> insertWorkoutLog(WorkoutLog log) async {
    final db = await database;
    return await db.insert('workout_logs', log.toMap());
  }

  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final db = await database;
    final maps = await db.query('workout_logs', orderBy: 'date DESC');
    return maps.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<List<WorkoutLog>> getWorkoutLogsByWorkoutId(int workoutId) async {
    final db = await database;
    final maps = await db.query(
      'workout_logs',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<List<WorkoutLog>> getRecentWorkoutLogs({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'workout_logs',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<List<WorkoutLog>> getWorkoutLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'workout_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<int> getTotalCompletedWorkouts() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_logs WHERE completed = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getWeeklyCompletionRate() async {
    final db = await database;
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_logs WHERE date >= ?',
      [lastWeek.toIso8601String()],
    );
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_logs WHERE date >= ? AND completed = 1',
      [lastWeek.toIso8601String()],
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    final completed = Sqflite.firstIntValue(completedResult) ?? 0;
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  Future<double> getAverageFatigueLevel() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(fatigue_level) as avg FROM workout_logs WHERE fatigue_level IS NOT NULL AND completed = 1',
    );
    if (result.isEmpty) return 0.0;
    final avg = result.first['avg'];
    return avg != null ? (avg as num).toDouble() : 0.0;
  }

  Future<int> getCurrentStreak() async {
    final db = await database;
    final logs = await db.query(
      'workout_logs',
      where: 'completed = 1',
      orderBy: 'date DESC',
    );
    if (logs.isEmpty) return 0;
    int streak = 0;
    DateTime? lastDate;
    for (var log in logs) {
      final logDate = DateTime.parse(log['date'] as String);
      if (lastDate == null) {
        final today = DateTime.now();
        final daysDiff = today.difference(logDate).inDays;
        if (daysDiff > 1) break;
        streak = 1;
        lastDate = logDate;
      } else {
        final daysDiff = lastDate.difference(logDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = logDate;
        } else if (daysDiff > 1) {
          break;
        }
      }
    }
    return streak;
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('workout_logs');
    await db.delete('exercises');
    await db.delete('workouts');
    await db.delete('programs');
    await db.delete('exercise_library'); // ✅ NEW
  }

  // ============================================
  // ✅ NEW: EXERCISE LIBRARY METHODS
  // ============================================

  Future<int> insertExercise(ExerciseLibrary exercise) async {
    final db = await database;
    return await db.insert('exercise_library', exercise.toMap());
  }

  Future<List<ExerciseLibrary>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_library',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ExerciseLibrary.fromMap(maps[i]));
  }

  Future<ExerciseLibrary?> getExerciseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_library',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ExerciseLibrary.fromMap(maps.first);
  }

  Future<int> toggleExerciseFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'exercise_library',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateExercise(ExerciseLibrary exercise) async {
    final db = await database;
    return await db.update(
      'exercise_library',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete(
      'exercise_library',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ExerciseLibrary>> searchExercises(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_library',
      where: 'name LIKE ? OR description LIKE ? OR muscleGroups LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ExerciseLibrary.fromMap(maps[i]));
  }

  Future<List<ExerciseLibrary>> getExercisesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_library',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ExerciseLibrary.fromMap(maps[i]));
  }

  Future<List<ExerciseLibrary>> getFavoriteExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_library',
      where: 'isFavorite = 1',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ExerciseLibrary.fromMap(maps[i]));
  }
}