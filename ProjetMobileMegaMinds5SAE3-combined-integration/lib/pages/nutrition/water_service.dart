import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'water_intake_model.dart';

class WaterService {
  static Database? _db;

  static Future<void> initDatabase() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'water.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table pour les consommations d'eau
        await db.execute('''
          CREATE TABLE water_intake(
            id TEXT PRIMARY KEY,
            amount INTEGER,
            timestamp TEXT
          )
        ''');
        
        // Table pour l'objectif
        await db.execute('''
          CREATE TABLE water_goal(
            id INTEGER PRIMARY KEY,
            dailyGoal INTEGER,
            remindersEnabled INTEGER
          )
        ''');
        
        // Insérer un objectif par défaut
        await db.insert('water_goal', {
          'id': 1,
          'dailyGoal': 2000,
          'remindersEnabled': 1,
        });
      },
    );
  }

  static Database get database {
    if (_db == null) {
      throw Exception("Database not initialized. Call WaterService.initDatabase() first.");
    }
    return _db!;
  }

  // Ajouter une consommation d'eau
  static Future<void> addWaterIntake(int amount) async {
    final intake = WaterIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
    );
    
    await database.insert(
      'water_intake',
      intake.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtenir toutes les consommations du jour
  static Future<List<WaterIntake>> getTodayIntakes() async {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> maps = await database.query(
      'water_intake',
      where: "date(timestamp) = ?",
      whereArgs: [dateString],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) => WaterIntake.fromMap(maps[i]));
  }

  // Calculer le total d'eau bu aujourd'hui
  static Future<int> getTodayTotal() async {
    final intakes = await getTodayIntakes();
    return intakes.fold<int>(0, (sum, intake) => sum + intake.amount);
  }

  // Obtenir l'objectif journalier
  static Future<WaterGoal> getGoal() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'water_goal',
      where: 'id = ?',
      whereArgs: [1],
    );
    
    if (maps.isEmpty) {
      final goal = WaterGoal();
      await database.insert('water_goal', goal.toMap());
      return goal;
    }
    
    return WaterGoal.fromMap(maps.first);
  }

  // Mettre à jour l'objectif journalier
  static Future<void> updateGoal(int newGoal) async {
    await database.update(
      'water_goal',
      {'dailyGoal': newGoal},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Activer/désactiver les rappels
  static Future<void> toggleReminders(bool enabled) async {
    await database.update(
      'water_goal',
      {'remindersEnabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Supprimer une consommation
  static Future<void> deleteIntake(String id) async {
    await database.delete(
      'water_intake',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtenir les consommations par jour (pour les graphiques)
  static Future<Map<DateTime, int>> getWeeklyData() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final List<Map<String, dynamic>> maps = await database.query(
      'water_intake',
      where: 'timestamp >= ?',
      whereArgs: [weekAgo.toIso8601String()],
    );
    
    final Map<DateTime, int> dailyTotals = {};
    
    // Initialiser les 7 derniers jours
    for (var i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      dailyTotals[dateKey] = 0;
    }
    
    // Agréger les données
    for (var map in maps) {
      final intake = WaterIntake.fromMap(map);
      final dateKey = DateTime(
        intake.timestamp.year,
        intake.timestamp.month,
        intake.timestamp.day,
      );
      
      if (dailyTotals.containsKey(dateKey)) {
        dailyTotals[dateKey] = dailyTotals[dateKey]! + intake.amount;
      }
    }
    
    return dailyTotals;
  }

  // Calculer le pourcentage de l'objectif atteint
  static Future<double> getProgressPercentage() async {
    final total = await getTodayTotal();
    final goal = await getGoal();
    return (total / goal.dailyGoal * 100).clamp(0.0, 100.0);
  }

  // Effacer toutes les données
  static Future<void> clearAllData() async {
    await database.delete('water_intake');
  }

  static Future<void> close() async {
    await _db?.close();
  }
}