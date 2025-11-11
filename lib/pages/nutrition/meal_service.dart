import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'meal_model.dart';

class MealService {
  static Database? _db;

  static Future<void> initDatabase() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meals.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meals(
            id TEXT PRIMARY KEY,
            name TEXT,
            imagePath TEXT,
            calories INTEGER,
            dateAdded TEXT,
            category INTEGER
          )
        ''');
      },
    );
  }

  static Database get database {
    if (_db == null) {
      throw Exception("Database not initialized. Call MealService.initDatabase() first.");
    }
    return _db!;
  }

  // Ajouter un repas
  static Future<void> addMeal(Meal meal) async {
    await database.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtenir tous les repas
  static Future<List<Meal>> getAllMeals() async {
    final List<Map<String, dynamic>> maps = await database.query('meals');
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  // Obtenir les repas d'aujourd'hui
  static Future<List<Meal>> getTodayMeals() async {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final List<Map<String, dynamic>> maps = await database.query(
      'meals',
      where: "date(dateAdded) = ?",
      whereArgs: [dateString],
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  // Supprimer un repas
  static Future<void> deleteMeal(String id) async {
    await database.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  // Mettre à jour un repas
  static Future<void> updateMeal(Meal meal) async {
    await database.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  // Calculer les calories totales du jour
  static Future<int> getTodayCalories() async {
    final meals = await getTodayMeals();
    return meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }

  // Obtenir les repas par date
  static Future<List<Meal>> getMealsByDate(DateTime date) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final List<Map<String, dynamic>> maps = await database.query(
      'meals',
      where: "date(dateAdded) = ?",
      whereArgs: [dateString],
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  // Supprimer tous les repas
  static Future<void> clearAllMeals() async {
    await database.delete('meals');
  }

  static Future<void> close() async {
    await _db?.close();
  }
}