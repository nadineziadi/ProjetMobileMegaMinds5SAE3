// lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mental_health_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mental_health.db');
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

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Table MoodEntry
    await db.execute('''
      CREATE TABLE mood_entries (
        id $idType,
        date $textType,
        mood $textType,
        intensity $intType,
        note TEXT
      )
    ''');

    // Table Quote
    await db.execute('''
      CREATE TABLE quotes (
        id $idType,
        text $textType,
        author $textType,
        fetchedAt TEXT,
        isFavorite $intType
      )
    ''');

    // Table MentalHealthStats
    await db.execute('''
      CREATE TABLE mental_health_stats (
        id $idType,
        mentalHealthScore $realType,
        caloriesBurned $intType,
        nutritionCalories $intType,
        sleepDurationMinutes $intType,
        heartRate $intType,
        date $textType
      )
    ''');

    // Table RelaxationExercise
    await db.execute('''
      CREATE TABLE relaxation_exercises (
        id $idType,
        title $textType,
        subtitle $textType,
        category $textType,
        durationMinutes $intType,
        audioUrl TEXT,
        imageUrl TEXT,
        isCompleted $intType,
        lastCompletedAt TEXT
      )
    ''');

    // Table WellnessPost
    await db.execute('''
      CREATE TABLE wellness_posts (
        id $idType,
        author $textType,
        content $textType,
        createdAt $textType,
        likes $intType,
        comments $intType,
        category $textType,
        isLiked $intType
      )
    ''');

    // Table DailyTask
    await db.execute('''
      CREATE TABLE daily_tasks (
        id $idType,
        title $textType,
        description $textType,
        scheduledTime $textType,
        isCompleted $intType,
        type $textType
      )
    ''');

    // Insérer des données initiales
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Exercices de relaxation par défaut
    final exercises = [
      RelaxationExercise(
        id: 'ex_1',
        title: 'Deep Breathing',
        subtitle: 'Calm your mind',
        category: 'breathing',
        durationMinutes: 5,
      ),
      RelaxationExercise(
        id: 'ex_2',
        title: 'Body Scan',
        subtitle: 'Release tension',
        category: 'meditation',
        durationMinutes: 10,
      ),
      RelaxationExercise(
        id: 'ex_3',
        title: 'Guided Meditation',
        subtitle: 'Inner peace',
        category: 'meditation',
        durationMinutes: 15,
      ),
      RelaxationExercise(
        id: 'ex_4',
        title: 'Peaceful Music',
        subtitle: 'Relax your soul',
        category: 'music',
        durationMinutes: 20,
      ),
      RelaxationExercise(
        id: 'ex_5',
        title: 'Morning Yoga',
        subtitle: 'Start your day right',
        category: 'yoga',
        durationMinutes: 15,
      ),
    ];

    for (var exercise in exercises) {
      await db.insert('relaxation_exercises', exercise.toMap());
    }

    // Posts du Wellness Hub par défaut
    final posts = [
      WellnessPost(
        id: 'post_1',
        author: 'Goal Ginger',
        content: 'Is there a therapy which can cure loneliness & Edem compulsion?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        likes: 2,
        comments: 0,
        category: 'therapy',
      ),
      WellnessPost(
        id: 'post_2',
        author: 'Pigeon Car',
        content: 'Feeling anxious about work deadlines. Any tips on managing stress?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        likes: 18,
        comments: 5,
        category: 'work',
      ),
      WellnessPost(
        id: 'post_3',
        author: 'Pleasant Car',
        content: 'Meditation has changed my life! Anyone else experiencing this?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 15,
        comments: 35,
        category: 'self-care',
      ),
    ];

    for (var post in posts) {
      await db.insert('wellness_posts', post.toMap());
    }

    // Tâches quotidiennes par défaut
    final tasks = [
      DailyTask(
        id: 'task_1',
        title: 'Peer Group Meetup',
        description: "Let's open up to the thing that matters among the people",
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        type: 'meetup',
      ),
      DailyTask(
        id: 'task_2',
        title: 'Meditation',
        description: 'Evening meditation session',
        scheduledTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          18,
          0,
        ),
        type: 'meditation',
      ),
    ];

    for (var task in tasks) {
      await db.insert('daily_tasks', task.toMap());
    }
  }

  // ========== CRUD pour MoodEntry ==========
  
  Future<String> createMoodEntry(MoodEntry entry) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newEntry = entry.copyWith(id: id);
    await db.insert('mood_entries', newEntry.toMap());
    return id;
  }

  Future<MoodEntry?> readMoodEntry(String id) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MoodEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MoodEntry>> getAllMoodEntries({int? limit}) async {
    final db = await database;
    final result = await db.query(
      'mood_entries',
      orderBy: 'date DESC',
      limit: limit,
    );

    return result.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'mood_entries',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return result.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<int> updateMoodEntry(MoodEntry entry) async {
    final db = await database;
    return db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteMoodEntry(String id) async {
    final db = await database;
    return await db.delete(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD pour Quote ==========

  Future<String> createQuote(Quote quote) async {
    final db = await database;
    await db.insert('quotes', quote.toMap());
    return quote.id;
  }

  Future<Quote?> getLatestQuote() async {
    final db = await database;
    final result = await db.query(
      'quotes',
      orderBy: 'fetchedAt DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Quote.fromMap(result.first);
    }
    return null;
  }

  Future<List<Quote>> getFavoriteQuotes() async {
    final db = await database;
    final result = await db.query(
      'quotes',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'fetchedAt DESC',
    );

    return result.map((map) => Quote.fromMap(map)).toList();
  }

  Future<int> updateQuote(Quote quote) async {
    final db = await database;
    return db.update(
      'quotes',
      quote.toMap(),
      where: 'id = ?',
      whereArgs: [quote.id],
    );
  }

  Future<int> toggleQuoteFavorite(String id, bool isFavorite) async {
    final db = await database;
    return db.update(
      'quotes',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD pour MentalHealthStats ==========

  Future<String> createMentalHealthStats(MentalHealthStats stats) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newStats = MentalHealthStats(
      id: id,
      mentalHealthScore: stats.mentalHealthScore,
      caloriesBurned: stats.caloriesBurned,
      nutritionCalories: stats.nutritionCalories,
      sleepDuration: stats.sleepDuration,
      heartRate: stats.heartRate,
      date: stats.date,
    );
    await db.insert('mental_health_stats', newStats.toMap());
    return id;
  }

  Future<MentalHealthStats?> getLatestMentalHealthStats() async {
    final db = await database;
    final result = await db.query(
      'mental_health_stats',
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return MentalHealthStats.fromMap(result.first);
    }
    return null;
  }

  Future<List<MentalHealthStats>> getMentalHealthStatsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'mental_health_stats',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return result.map((map) => MentalHealthStats.fromMap(map)).toList();
  }

  // ========== CRUD pour RelaxationExercise ==========

  Future<List<RelaxationExercise>> getAllExercises() async {
    final db = await database;
    final result = await db.query('relaxation_exercises');
    return result.map((map) => RelaxationExercise.fromMap(map)).toList();
  }

  Future<List<RelaxationExercise>> getExercisesByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'relaxation_exercises',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((map) => RelaxationExercise.fromMap(map)).toList();
  }

  Future<int> updateExercise(RelaxationExercise exercise) async {
    final db = await database;
    return db.update(
      'relaxation_exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> markExerciseCompleted(String id) async {
    final db = await database;
    return db.update(
      'relaxation_exercises',
      {
        'isCompleted': 1,
        'lastCompletedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD pour WellnessPost ==========

  Future<List<WellnessPost>> getAllPosts({String? category}) async {
    final db = await database;
    
    if (category != null) {
      final result = await db.query(
        'wellness_posts',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'createdAt DESC',
      );
      return result.map((map) => WellnessPost.fromMap(map)).toList();
    } else {
      final result = await db.query(
        'wellness_posts',
        orderBy: 'createdAt DESC',
      );
      return result.map((map) => WellnessPost.fromMap(map)).toList();
    }
  }

  Future<String> createPost(WellnessPost post) async {
    final db = await database;
    await db.insert('wellness_posts', post.toMap());
    return post.id;
  }

  Future<int> updatePost(WellnessPost post) async {
    final db = await database;
    return db.update(
      'wellness_posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> togglePostLike(String id, bool isLiked, int currentLikes) async {
    final db = await database;
    final newLikes = isLiked ? currentLikes + 1 : currentLikes - 1;
    return db.update(
      'wellness_posts',
      {
        'isLiked': isLiked ? 1 : 0,
        'likes': newLikes,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD pour DailyTask ==========

  Future<List<DailyTask>> getTodayTasks() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'daily_tasks',
      where: 'scheduledTime BETWEEN ? AND ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'scheduledTime ASC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  Future<String> createTask(DailyTask task) async {
    final db = await database;
    await db.insert('daily_tasks', task.toMap());
    return task.id;
  }

  Future<int> updateTask(DailyTask task) async {
    final db = await database;
    return db.update(
      'daily_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> toggleTaskCompletion(String id, bool isCompleted) async {
    final db = await database;
    return db.update(
      'daily_tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      'daily_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== Utilitaires ==========

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('mood_entries');
    await db.delete('quotes');
    await db.delete('mental_health_stats');
    await db.delete('wellness_posts');
    await db.delete('daily_tasks');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}