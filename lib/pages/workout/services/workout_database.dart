import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_model.dart';

class WorkoutDatabase {
  static final WorkoutDatabase instance = WorkoutDatabase._init();
  static Database? _database;

  WorkoutDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workouts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        caloriesBurned INTEGER,
        notes TEXT
      )
    ''');
  }

  Future<int> create(Workout workout) async {
    final db = await instance.database;
    return await db.insert('workouts', _sanitizeWorkout(workout));
  }

  Future<List<Workout>> readAll() async {
    final db = await instance.database;
    final result = await db.query('workouts', orderBy: 'date DESC');
    return result.map((map) => Workout.fromMap(map)).toList();
  }

  Future<int> update(Workout workout) async {
    if (workout.id == null) {
      throw Exception('Cannot update workout without an ID');
    }
    final db = await instance.database;
    return await db.update(
      'workouts',
      _sanitizeWorkout(workout),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Convert nulls to safe defaults
  Map<String, dynamic> _sanitizeWorkout(Workout workout) {
    return {
      'id': workout.id,
      'name': workout.name ?? '',
      'type': workout.type ?? '',
      'duration': workout.duration ?? 0,
      'caloriesBurned': workout.caloriesBurned ?? 0,
      'date': workout.date?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'notes': workout.notes ?? '',
    };
  }
}
