import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _usersKey = 'gymini_users';
  static const String _currentUserIdKey = 'gymini_current_user_id';
  static const String _adminInitializedKey = 'gymini_admin_initialized';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _createDefaultAdminIfNeeded();
    print('✅ StorageService initialized');
  }

  Future<void> _createDefaultAdminIfNeeded() async {
    final adminInitialized = _prefs!.getBool(_adminInitializedKey) ?? false;
    
    if (!adminInitialized) {
      final users = await getAllUsers();
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
  }

  Future<void> _saveAllUsers(List<UserProfile> users) async {
    final usersJson = users.map((u) => u.toJson()).toList();
    final usersString = jsonEncode(usersJson);
    await _prefs!.setString(_usersKey, usersString);
  }

  Future<List<UserProfile>> getAllUsers() async {
    final usersString = _prefs!.getString(_usersKey);
    if (usersString == null || usersString.isEmpty) return [];

    try {
      final List<dynamic> usersJson = jsonDecode(usersString);
      return usersJson.map((json) => UserProfile.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<UserProfile> createUser(UserProfile user) async {
    final users = await getAllUsers();
    if (users.any((u) => u.email == user.email)) {
      throw Exception('Un compte avec cet email existe déjà');
    }
    users.add(user);
    await _saveAllUsers(users);
    await setCurrentUserId(user.id);
    return user;
  }

  Future<UserProfile?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<UserProfile?> getUserById(String userId) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserProfile user) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
      await _saveAllUsers(users);
    }
  }

  Future<void> deleteUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.id == userId);
    await _saveAllUsers(users);
  }

  Future<void> setCurrentUserId(String userId) async {
    await _prefs!.setString(_currentUserIdKey, userId);
  }

  Future<String?> getCurrentUserId() async {
    return _prefs!.getString(_currentUserIdKey);
  }

  Future<void> clearSession() async {
    await _prefs!.remove(_currentUserIdKey);
  }

  Future<void> clearAllData() async {
    await _prefs!.clear();
    await _createDefaultAdminIfNeeded();
  }
}