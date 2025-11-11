import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('🗄️ Initializing SQLite database...');
    
    try {
      String path;
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop: utiliser le dossier d'application
        final appDocDir = Directory.current.path;
        path = join(appDocDir, 'data', 'gymini.db');
        
        // Créer le dossier data s'il n'existe pas
        final dataDir = Directory(join(appDocDir, 'data'));
        if (!await dataDir.exists()) {
          await dataDir.create(recursive: true);
        }
      } else {
        // Mobile: utiliser getDatabasesPath
        final databasePath = await getDatabasesPath();
        path = join(databasePath, 'gymini.db');
      }

      print('📁 Database path: $path');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      print('❌ Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    print('📊 Creating database tables...');
    
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        gender TEXT NOT NULL,
        fitnessLevel TEXT NOT NULL,
        goal TEXT NOT NULL,
        avatarUrl TEXT,
        createdAt TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        badges TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE session (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    print('✅ Database tables created');
    await _createDefaultAdmin(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    try {
      final adminExists = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['admin@gymini.com'],
      );

      if (adminExists.isEmpty) {
        await db.insert('users', {
          'id': 'admin_001',
          'name': 'Admin GYMINI',
          'email': 'admin@gymini.com',
          'password': 'admin123',
          'role': 'admin',
          'age': 30,
          'weight': 75.0,
          'height': 175.0,
          'gender': 'male',
          'fitnessLevel': 'advanced',
          'goal': 'maintenance',
          'avatarUrl': null,
          'createdAt': DateTime.now().toIso8601String(),
          'lastUpdated': DateTime.now().toIso8601String(),
          'badges': jsonEncode([]),
        });
        print('🔑 Admin créé: admin@gymini.com / admin123');
      }
    } catch (e) {
      print('⚠️ Error creating admin: $e');
    }
  }

  // === USER OPERATIONS ===

  Future<UserProfile> createUser(UserProfile user) async {
    final db = await database;
    
    final existing = await getUserByEmail(user.email);
    if (existing != null) {
      throw Exception('Un compte avec cet email existe déjà');
    }
    
    await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'role': user.role.name,
      'age': user.age,
      'weight': user.weight,
      'height': user.height,
      'gender': user.gender,
      'fitnessLevel': user.fitnessLevel,
      'goal': user.goal,
      'avatarUrl': user.avatarUrl,
      'createdAt': user.createdAt.toIso8601String(),
      'lastUpdated': user.lastUpdated.toIso8601String(),
      'badges': jsonEncode(user.badges),
    });

    for (var entry in user.weightHistory) {
      await db.insert('weight_history', {
        'userId': user.id,
        'date': entry.date.toIso8601String(),
        'weight': entry.weight,
      });
    }

    return user;
  }

  Future<UserProfile?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isEmpty) return null;
    return await _mapToUserProfile(results.first);
  }

  Future<UserProfile?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (results.isEmpty) return null;
    return await _mapToUserProfile(results.first);
  }

  Future<List<UserProfile>> getAllUsers() async {
    final db = await database;
    final results = await db.query('users');
    final users = <UserProfile>[];
    for (var map in results) {
      users.add(await _mapToUserProfile(map));
    }
    return users;
  }

  Future<UserProfile> _mapToUserProfile(Map<String, dynamic> map) async {
    final db = await database;
    
    final weightHistoryResults = await db.query(
      'weight_history',
      where: 'userId = ?',
      whereArgs: [map['id']],
      orderBy: 'date ASC',
    );

    final weightHistory = weightHistoryResults.map((w) => WeightEntry(
      date: DateTime.parse(w['date'] as String),
      weight: (w['weight'] as num).toDouble(),
    )).toList();

    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] as String),
        orElse: () => UserRole.user,
      ),
      age: map['age'] as int,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      gender: map['gender'] as String,
      fitnessLevel: map['fitnessLevel'] as String,
      goal: map['goal'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      weightHistory: weightHistory,
      badges: List<String>.from(jsonDecode(map['badges'] as String)),
    );
  }

  Future<void> updateUser(UserProfile user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'name': user.name,
        'age': user.age,
        'weight': user.weight,
        'height': user.height,
        'gender': user.gender,
        'fitnessLevel': user.fitnessLevel,
        'goal': user.goal,
        'avatarUrl': user.avatarUrl,
        'role': user.role.name,
        'lastUpdated': DateTime.now().toIso8601String(),
        'badges': jsonEncode(user.badges),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> addWeightEntry(String userId, WeightEntry entry) async {
    final db = await database;
    await db.insert('weight_history', {
      'userId': userId,
      'date': entry.date.toIso8601String(),
      'weight': entry.weight,
    });
    await db.update(
      'users',
      {'weight': entry.weight},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete('weight_history', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // === SESSION ===

  Future<void> setCurrentUserId(String userId) async {
    final db = await database;
    await db.insert(
      'session',
      {'key': 'current_user_id', 'value': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCurrentUserId() async {
    final db = await database;
    final results = await db.query(
      'session',
      where: 'key = ?',
      whereArgs: ['current_user_id'],
    );
    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete(
      'session',
      where: 'key = ?',
      whereArgs: ['current_user_id'],
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}