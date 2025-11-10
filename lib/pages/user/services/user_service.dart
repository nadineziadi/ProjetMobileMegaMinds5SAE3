import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class UserService {
  static const String _usersKey = 'gymini_users';
  static const String _currentUserIdKey = 'gymini_current_user_id';
  static const String _adminInitializedKey = 'gymini_admin_initialized';

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized && _prefs != null) {
      print('✅ UserService already initialized');
      return;
    }
    
    try {
      print('📦 Getting SharedPreferences instance...');
      _prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ SharedPreferences timeout - using mock');
          throw Exception('Timeout');
        },
      );
      
      _isInitialized = true;
      print('✅ SharedPreferences initialized');
      
      await _createDefaultAdminIfNeeded();
      print('✅ UserService initialization complete');
    } catch (e) {
      print('❌ Error initializing UserService: $e');
      // Continuer quand même pour ne pas bloquer l'app
      _isInitialized = true;
    }
  }

  // Créer un admin par défaut si aucun admin n'existe
  Future<void> _createDefaultAdminIfNeeded() async {
    if (_prefs == null) return;
    
    try {
      final adminInitialized = _prefs!.getBool(_adminInitializedKey) ?? false;
      
      if (!adminInitialized) {
        final users = await _getAllUsers();
        final hasAdmin = users.any((u) => u.role == UserRole.admin);
        
        if (!hasAdmin) {
          final admin = UserProfile(
            id: 'admin_001',
            name: 'Admin GYMINI',
            email: 'admin@gymini.com',
            password: 'admin123',
            role: UserRole.admin,
            age: 30,
            weight: 75.0,
            height: 175.0,
            gender: 'male',
            fitnessLevel: 'advanced',
            goal: 'maintenance',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
          
          users.add(admin);
          await _saveAllUsers(users);
          await _prefs!.setBool(_adminInitializedKey, true);
          
          print('🔑 Admin créé: admin@gymini.com / admin123');
        }
      }
    } catch (e) {
      print('⚠️ Error creating admin: $e');
    }
  }

  Future<void> _saveAllUsers(List<UserProfile> users) async {
    if (_prefs == null) return;
    
    try {
      final usersJson = users.map((u) => u.toJson()).toList();
      final usersString = jsonEncode(usersJson);
      await _prefs!.setString(_usersKey, usersString);
      print('💾 Saved ${users.length} users');
    } catch (e) {
      print('❌ Error saving users: $e');
    }
  }

  Future<List<UserProfile>> _getAllUsers() async {
    if (_prefs == null) return [];
    
    try {
      final usersString = _prefs!.getString(_usersKey);
      
      if (usersString == null || usersString.isEmpty) {
        return [];
      }

      final List<dynamic> usersJson = jsonDecode(usersString);
      return usersJson
          .map((json) => UserProfile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading users: $e');
      return [];
    }
  }

  Future<UserProfile> createUser({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String fitnessLevel,
    required String goal,
    UserRole role = UserRole.user,
  }) async {
    await init();
    
    final existingUsers = await _getAllUsers();
    if (existingUsers.any((u) => u.email == email)) {
      throw Exception('Un compte avec cet email existe déjà');
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();

    final user = UserProfile(
      id: userId,
      name: name,
      email: email,
      password: password,
      role: role,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      fitnessLevel: fitnessLevel,
      goal: goal,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      weightHistory: [WeightEntry(date: DateTime.now(), weight: weight)],
      badges: [],
    );

    existingUsers.add(user);
    await _saveAllUsers(existingUsers);
    
    if (_prefs != null) {
      await _prefs!.setString(_currentUserIdKey, userId);
    }
    
    print('✅ User created: ${user.email} (${user.role.name})');
    return user;
  }

  Future<UserProfile?> login(String email, String password) async {
    await init();
    final users = await _getAllUsers();
    
    try {
      final user = users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      
      if (_prefs != null) {
        await _prefs!.setString(_currentUserIdKey, user.id);
      }
      print('✅ Login successful: ${user.email} (${user.role.name})');
      return user;
    } catch (e) {
      print('❌ Login failed for: $email');
      return null;
    }
  }

  Future<UserProfile?> getCurrentUser() async {
    await init();
    
    if (_prefs == null) return null;
    
    final userId = _prefs!.getString(_currentUserIdKey);
    
    if (userId == null) return null;

    final users = await _getAllUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    await init();
    
    if (_prefs == null) return false;
    
    return _prefs!.containsKey(_currentUserIdKey);
  }

  Future<void> updateUser(UserProfile user) async {
    await init();
    user.lastUpdated = DateTime.now();
    
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    
    if (index != -1) {
      users[index] = user;
      await _saveAllUsers(users);
    }
  }

  Future<void> logout() async {
    await init();
    
    if (_prefs != null) {
      await _prefs!.remove(_currentUserIdKey);
    }
    print('👋 User logged out');
  }

  // MÉTHODES ADMIN
  Future<List<UserProfile>> getAllUsersForAdmin() async {
    await init();
    return await _getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await init();
    final users = await _getAllUsers();
    users.removeWhere((u) => u.id == userId);
    await _saveAllUsers(users);
    print('🗑️ User deleted: $userId');
  }

  Future<void> promoteToAdmin(String userId) async {
    await init();
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    
    if (index != -1) {
      users[index].role = UserRole.admin;
      await _saveAllUsers(users);
      print('⬆️ User promoted to admin: ${users[index].email}');
    }
  }
}