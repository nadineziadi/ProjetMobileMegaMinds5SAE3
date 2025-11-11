
import '../models/user_model.dart';
import 'database_helper.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final DatabaseHelper _db = DatabaseHelper();

  Future<void> init() async {
    try {
      print('📦 Initializing UserService with SQLite...');
      await _db.database;
      print('✅ UserService initialized');
    } catch (e) {
      print('❌ Error initializing UserService: $e');
      rethrow;
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

    await _db.createUser(user);
    await _db.setCurrentUserId(userId);

    print('✅ User created: ${user.email}');
    return user;
  }

  Future<UserProfile?> login(String email, String password) async {
    final user = await _db.getUserByEmail(email);

    if (user == null || user.password != password) {
      return null;
    }

    await _db.setCurrentUserId(user.id);
    print('✅ Login: ${user.email} (${user.role.name})');
    return user;
  }

  Future<UserProfile?> getCurrentUser() async {
    final userId = await _db.getCurrentUserId();
    if (userId == null) return null;
    return await _db.getUserById(userId);
  }

  Future<bool> isLoggedIn() async {
    final userId = await _db.getCurrentUserId();
    return userId != null;
  }

  Future<void> updateUser(UserProfile user) async {
    await _db.updateUser(user);
  }

  Future<void> addWeightEntry(String userId, double weight) async {
    final entry = WeightEntry(date: DateTime.now(), weight: weight);
    await _db.addWeightEntry(userId, entry);
  }

  Future<void> logout() async {
    await _db.clearSession();
    print('👋 Logged out');
  }

  Future<List<UserProfile>> getAllUsersForAdmin() async {
    return await _db.getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await _db.deleteUser(userId);
  }

  Future<void> promoteToAdmin(String userId) async {
    final user = await _db.getUserById(userId);
    if (user != null) {
      user.role = UserRole.admin;
      await _db.updateUser(user);
      print('⬆️ Promoted: ${user.email}');
    }
  }
}